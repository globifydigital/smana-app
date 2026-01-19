import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/payment_models.dart';
import '../models/cart_item.dart';

class BillingInfoDialog extends ConsumerStatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String notes;

  const BillingInfoDialog({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.notes,
  });

  @override
  ConsumerState<BillingInfoDialog> createState() => _BillingInfoDialogState();
}

class _BillingInfoDialogState extends ConsumerState<BillingInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  // PaymentService removed
  // _isLoading removed (dialog closes instantly)

  // Controllers
  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'AE');

  @override
  void initState() {
    super.initState();
    _loadBillingDetails();
  }

  Future<void> _loadBillingDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _givenNameController.text = prefs.getString('billing_given_name') ?? '';
      _surnameController.text = prefs.getString('billing_surname') ?? '';
      _emailController.text = prefs.getString('billing_email') ?? '';
      _streetController.text = prefs.getString('billing_street') ?? '';
      _cityController.text = prefs.getString('billing_city') ?? '';
      _stateController.text = prefs.getString('billing_state') ?? '';
      _postcodeController.text = prefs.getString('billing_postcode') ?? '';
      _countryController.text = prefs.getString('billing_country') ?? 'AE';
    });
  }

  Future<void> _saveBillingDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('billing_given_name', _givenNameController.text);
    await prefs.setString('billing_surname', _surnameController.text);
    await prefs.setString('billing_email', _emailController.text);
    await prefs.setString('billing_street', _streetController.text);
    await prefs.setString('billing_city', _cityController.text);
    await prefs.setString('billing_state', _stateController.text);
    await prefs.setString('billing_postcode', _postcodeController.text);
    await prefs.setString('billing_country', _countryController.text);
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postcodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Save details
    await _saveBillingDetails();

    final billingAddress = BillingAddress(
      givenName: _givenNameController.text,
      surname: _surnameController.text,
      street1: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      postcode: _postcodeController.text,
    );

    // Return the result
    if (mounted) {
      Navigator.of(
        context,
      ).pop({'billingAddress': billingAddress, 'email': _emailController.text});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Billing Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('First Name', _givenNameController),
                _buildTextField('Last Name', _surnameController),
                _buildTextField('Email', _emailController, email: true),
                const Divider(color: Colors.white24, height: 32),
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField('Street', _streetController),
                Row(
                  children: [
                    Expanded(child: _buildTextField('City', _cityController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('State', _stateController)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Country (ISO)',
                        _countryController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField('Postcode', _postcodeController),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) =>
            value?.isEmpty ?? true ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
