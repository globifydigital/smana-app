import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dining_provider.dart';
import '../providers/cart_provider.dart';
import '../models/menu_item.dart';

class DiningScreen extends ConsumerWidget {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diningState = ref.watch(diningProvider);
    final filteredItems = diningState.filteredItems;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Dining'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/orders'),
          ),
        ],
      ),
      body: diningState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.goldPrimary),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Banner
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Signature Dining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Categories
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildChip(
                        ref,
                        'All',
                        diningState.selectedCategory == 'All',
                      ),
                      _buildChip(
                        ref,
                        'Appetizer',
                        diningState.selectedCategory == 'Appetizer',
                      ),
                      _buildChip(
                        ref,
                        'Main Course',
                        diningState.selectedCategory == 'Main Course',
                      ),
                      _buildChip(
                        ref,
                        'Dessert',
                        diningState.selectedCategory == 'Dessert',
                      ),
                      _buildChip(
                        ref,
                        'Beverage',
                        diningState.selectedCategory == 'Beverage',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dishes or Empty State
                if (filteredItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No items found in this category',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  ...filteredItems
                      .map((item) => _buildDishCard(ref, item, context))
                      .toList(), // Pass ref and context
              ],
            ),
      floatingActionButton: ref.watch(cartProvider).totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/cart'),
              backgroundColor: AppTheme.goldPrimary,
              label: Text(
                'View Cart (${ref.watch(cartProvider).totalItems})',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildChip(WidgetRef ref, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        backgroundColor: isSelected ? AppTheme.goldPrimary : Colors.white10,
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
        side: BorderSide.none,
        onPressed: () {
          ref.read(diningProvider.notifier).setCategory(label);
        },
      ),
    );
  }

  Widget _buildDishCard(WidgetRef ref, MenuItem item, BuildContext context) {
    final qty = ref.watch(cartProvider).getItemQuantity(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? item.imageUrl!
                  : 'https://via.placeholder.com/100', // Fallback
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                child: const Icon(Icons.restaurant, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AED ${item.price}',
                        style: const TextStyle(
                          color: AppTheme.goldPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: qty == 0
                            ? IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addToCart(item);
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.name} added to cart',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .removeFromCart(item);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .addToCart(item);
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
