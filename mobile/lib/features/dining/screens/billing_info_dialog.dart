import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/payment_models.dart';
import '../models/cart_item.dart';
import '../providers/payment_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'hyperpay_webview.dart';
import 'dart:convert';

class BillingInfoDialog extends ConsumerStatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String? notes;
  final VoidCallback onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const BillingInfoDialog({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    this.notes,
    required this.onPaymentSuccess,
    this.onPaymentFailed,
  });

  @override
  ConsumerState<BillingInfoDialog> createState() => _BillingInfoDialogState();
}

class _BillingInfoDialogState extends ConsumerState<BillingInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _street1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _secureStorage = SecureStorageService();
  String _selectedCountry = 'AE';
  String _selectedCurrency = 'AED';
  bool _saveBillingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadSavedBillingInfo();
  }

  Future<void> _loadSavedBillingInfo() async {
    final savedBilling = await _secureStorage.read('billing_info');

    if (savedBilling != null) {
      try {
        final billingData = json.decode(savedBilling) as Map<String, dynamic>;
        setState(() {
          _givenNameController.text = billingData['givenName'] ?? '';
          _surnameController.text = billingData['surname'] ?? '';
          _emailController.text = billingData['email'] ?? '';
          _street1Controller.text = billingData['street1'] ?? '';
          _cityController.text = billingData['city'] ?? '';
          _stateController.text = billingData['state'] ?? '';
          _postcodeController.text = billingData['postcode'] ?? '';
          _selectedCountry = billingData['country'] ?? 'AE';
          _selectedCurrency = billingData['country'] == 'US' ? 'USD' : 'AED';
        });
      } catch (e) {
        print('Error loading saved billing info: $e');
      }
    }

    _preFillUserData();
  }

  void _preFillUserData() {
    final authState = ref.read(authProvider);
    final guest = authState.guest;
    if (guest != null) {
      if (_emailController.text.isEmpty) {
        _emailController.text = guest.email;
      }
      if (_givenNameController.text.isEmpty && guest.name.isNotEmpty) {
        _givenNameController.text = guest.name.split(' ').first;
        if (guest.name.contains(' ')) {
          _surnameController.text = guest.name.split(' ').skip(1).join(' ');
        }
      }
    }
  }

  Future<void> _saveBillingInfoToStorage() async {
    if (_saveBillingInfo) {
      final billingData = {
        'givenName': _givenNameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'street1': _street1Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postcode': _postcodeController.text.trim(),
        'country': _selectedCountry,
      };
      await _secureStorage.write('billing_info', json.encode(billingData));
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    final guest = authState.guest;

    if (guest == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final items = widget.cartItems
        .map(
          (item) => {'menuItemId': item.menuItem.id, 'quantity': item.quantity},
        )
        .toList();

    try {
      final response = await ref
          .read(paymentProvider.notifier)
          .createCheckoutWithItems(
            items: items,
            roomNumber: guest.roomNumber ?? '',
            notes: widget.notes ?? '',
            currency: _selectedCurrency,
            customerEmail: _emailController.text.trim(),
            billingAddress: BillingAddress(
              givenName: _givenNameController.text.trim(),
              surname: _surnameController.text.trim(),
              street1: _street1Controller.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              country: _selectedCountry,
              postcode: _postcodeController.text.trim(),
            ),
          );

      if (response == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create payment session'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final checkoutId = response['checkoutId'];
      await _saveBillingInfoToStorage();

      if (!mounted) return;
      Navigator.of(context).pop();
      _showPaymentInstructions(checkoutId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      if (widget.onPaymentFailed != null) widget.onPaymentFailed!();
    }
  }

  void _showPaymentInstructions(String checkoutId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => HyperPayWebView(
          checkoutId: checkoutId,
          shopperResultUrl: 'smana://payment',
          onPaymentComplete: (status) async {
            if (status == 'completed') {
              // Verify payment status
              final paymentStatus = await ref
                  .read(paymentProvider.notifier)
                  .getPaymentStatus(checkoutId);

              if (paymentStatus != null && paymentStatus.success) {
                Navigator.of(context).pop(true); // Return success
              } else {
                Navigator.of(context).pop(false); // Return failure
              }
            } else if (status == 'cancelled') {
              Navigator.of(context).pop(false); // Return cancelled
            }
          },
        ),
      ),
    );

    // Handle result after WebView closes
    if (!mounted) return;

    if (result == true) {
      widget.onPaymentSuccess();
    } else if (result == false) {
      if (widget.onPaymentFailed != null) widget.onPaymentFailed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);

    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      title: const Text(
        'Billing Information',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_givenNameController, 'First Name'),
              _buildTextField(_surnameController, 'Last Name'),
              _buildTextField(_emailController, 'Email', isEmail: true),
              _buildTextField(_street1Controller, 'Street Address'),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_stateController, 'State/Province'),
              _buildTextField(_postcodeController, 'Postal Code'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Country',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF3a3a3a),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'AE', child: Text('UAE')),
                  DropdownMenuItem(value: 'SA', child: Text('Saudi Arabia')),
                  DropdownMenuItem(value: 'US', child: Text('United States')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                    _selectedCurrency = value == 'US' ? 'USD' : 'AED';
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Currency:', style: TextStyle(color: Colors.white70)),
                  Text(
                    _selectedCurrency,
                    style: TextStyle(
                      color: AppTheme.goldPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '$_selectedCurrency ${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.goldPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _saveBillingInfo,
                onChanged: (value) =>
                    setState(() => _saveBillingInfo = value ?? true),
                title: Text(
                  'Save billing info for future orders',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                activeColor: AppTheme.goldPrimary,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: paymentState.isLoading ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldPrimary,
            foregroundColor: Colors.black,
          ),
          child: paymentState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Pay Now'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _street1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }
}
