import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    // Listen for success
    ref.listen(cartProvider, (previous, next) {
      if (next.isOrderSuccess && !next.isLoading) {
        // Show success and pop
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.pop(); // Go back to Dining
        ref
            .read(cartProvider.notifier)
            .clearCart(); // Clear after success logic if needed, or before
        // Actually provider implementation clears it by setting new state?
        // My implementation: state = CartState(isOrderSuccess: true); which clears items. Correct.
      }
      if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

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
                      // Payment Method
                      const Text(
                        'Payment Method',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPaymentOption(
                              ref,
                              'Cash',
                              Icons.money,
                              cartState.paymentMethod == 'Cash',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPaymentOption(
                              ref,
                              'Online',
                              Icons.credit_card,
                              cartState.paymentMethod == 'Online',
                            ),
                          ),
                        ],
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
                        onPressed: cartState.isLoading
                            ? null
                            : () {
                                ref
                                    .read(cartProvider.notifier)
                                    .placeOrder(_notesController.text);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: cartState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Place Order',
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

  Widget _buildPaymentOption(
    WidgetRef ref,
    String method,
    IconData icon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(cartProvider.notifier).setPaymentMethod(method);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldPrimary.withOpacity(0.2)
              : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.goldPrimary : Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              method,
              style: TextStyle(
                color: isSelected ? AppTheme.goldPrimary : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
