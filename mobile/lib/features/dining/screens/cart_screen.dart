import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';
import 'billing_info_dialog.dart';
import '../../../../core/services/payment_service.dart';
import '../models/payment_models.dart';
import 'hyperpay_webview.dart';
import '../../auth/providers/auth_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _notesController = TextEditingController();
  final _paymentService = PaymentService();
  bool _isPaymentProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('My Cart')),
      body: cartState.items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                (item.menuItem.imageUrl != null &&
                                        item.menuItem.imageUrl!.isNotEmpty)
                                    ? item.menuItem.imageUrl!
                                    : 'https://via.placeholder.com/60',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'AED ${item.menuItem.price}',
                                    style: const TextStyle(
                                      color: AppTheme.goldPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Qty
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .removeFromCart(item.menuItem);
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppTheme.goldPrimary,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addToCart(item.menuItem);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Notes
                      TextField(
                        controller: _notesController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add notes (allergies, extra sauce...)',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.goldPrimary.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.payment,
                              color: AppTheme.goldPrimary,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Secure Payment via HyperPay',
                                style: TextStyle(
                                  color: AppTheme.goldPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'AED ${cartState.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.goldPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Button
                      ElevatedButton(
                        onPressed: cartState.isLoading || _isPaymentProcessing
                            ? null
                            : () => _handleHyperPayCheckout(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: cartState.isLoading || _isPaymentProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Pay with HyperPay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _handleHyperPayCheckout(WidgetRef ref) async {
    final cartState = ref.read(cartProvider);
    final authState = ref.read(authProvider);

    if (!mounted) return;

    // 1. Show Billing Dialog and await result
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BillingInfoDialog(
        cartItems: cartState.items,
        totalAmount: cartState.totalAmount,
        notes: _notesController.text,
      ),
    );

    if (result == null) return; // User cancelled

    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      final billingAddress = result['billingAddress'] as BillingAddress;
      final email = result['email'] as String;
      // Dynamic room number from auth provider
      final roomNumber = authState.guest?.roomNumber ?? '000';

      // 2. Create Checkout
      final checkoutResult = await _paymentService.createCheckoutWithItems(
        items: cartState.items.map((item) {
          return {'menuItemId': item.menuItem.id, 'quantity': item.quantity};
        }).toList(),
        roomNumber: roomNumber,
        notes: _notesController.text,
        currency: 'AED',
        customerEmail: email,
        billingAddress: billingAddress,
      );

      final checkoutId = checkoutResult['checkoutId'] as String;
      final integrity = checkoutResult['integrity'] as String?;

      if (!mounted) return;

      // 3. Navigate to Payment WebView
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HyperPayWebView(
            checkoutId: checkoutId,
            integrity: integrity ?? '',
            shopperResultUrl: 'https://smana.app/payment/result',
            mode: 'test',
            onPaymentSuccess: (resourcePath) async {
              // Verify payment status
              try {
                final status = await _paymentService.getPaymentStatus(
                  checkoutId,
                );
                if (status.success || status.pending) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close WebView
                    _showSuccessDialog();
                  }
                } else {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close WebView
                    _showFailureDialog(
                      'Payment failed: ${status.result.description}',
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  _showFailureDialog('Verification failed: $e');
                }
              }
            },
            onPaymentError: (error) {
              if (mounted) {
                Navigator.of(context).pop(); // Close WebView
                _showFailureDialog(error);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showFailureDialog('Failed to initiate payment: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaymentProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    // Clear cart
    ref.read(cartProvider.notifier).clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Text(
              'Payment Successful!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your order has been placed successfully.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Our kitchen has received your order and will start preparing it shortly.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              context.go('/orders'); // Navigate to Current Orders
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View Current Orders'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(
              'Payment Failed',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'You can view this attempt in your order history.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Stay on cart
            },
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear cart if desired, or keep it.
              // Logic: Failed payment usually creates a "Failed" order in backend?
              // The CartProvider `placeOrder` logic isn't used here directly yet for failed ones unless backend creates it.
              // Assuming backend creates a pending/failed order via webhook or initial create.
              // For now, we just navigate.
              Navigator.of(dialogContext).pop();
              context.go('/orders?tab=previous'); // Navigate to Previous Orders
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Previous Orders'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
