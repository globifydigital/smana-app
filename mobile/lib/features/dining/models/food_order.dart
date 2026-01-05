import 'menu_item.dart';

class FoodOrder {
  final String id;
  final String roomNumber;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? paymentStatus;
  final String? currency;
  final DateTime createdAt;

  FoodOrder({
    required this.id,
    required this.roomNumber,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.paymentStatus,
    this.currency,
    required this.createdAt,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: json['_id'],
      roomNumber: json['roomNumber'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      notes: json['notes'],
      paymentStatus: json['paymentStatus'],
      currency: json['currency'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderItem {
  final MenuItem
  menuItem; // We might need to handle if 'menuItemId' is populated or not.
  // Backend populate('items.menuItemId') isn't default in getMyOrders.
  // Wait, backend model:
  // items: [{ menuItemId: ObjectId, name: String, quantity: Number, price: Number }]
  // It copies name and price at time of order. So we don't strictly need the full MenuItem object if we just show name/price.
  // BUT the frontend might expect MenuItem structure or simple fields.
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.menuItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Assuming backend provided 'name', 'quantity', 'price' in the item object
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      menuItem: MenuItem(
        id: json['menuItemId'] ?? '',
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        description: '',
        category: '',
        isActive: true, // Placeholder
        imageUrl:
            '', // We don't have this in the embedded item unless populated?
      ),
    );
  }
}
