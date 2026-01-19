import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/order_provider.dart';
import '../models/food_order.dart'; // Ensure correct import
import 'package:intl/intl.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Previous Orders'),
        backgroundColor: Colors.transparent,
      ),
      body: orderState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.goldPrimary),
            )
          : orderState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${orderState.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(orderProvider.notifier).fetchOrders(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
          : orderState.orders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () => ref.read(orderProvider.notifier).fetchOrders(),
              color: AppTheme.goldPrimary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderState.orders.length,
                itemBuilder: (context, index) {
                  final order = orderState.orders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No orders yet',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(FoodOrder order) {
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'preparing':
        statusColor = Colors.blue;
        break;
      case 'ready':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    final dateStr = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Text(
                    '${item.quantity}x',
                    style: const TextStyle(
                      color: AppTheme.goldPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Text(
                    'AED ${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 24),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'AED ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.goldPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
