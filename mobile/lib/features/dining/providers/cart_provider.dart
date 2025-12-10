import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../../auth/providers/auth_provider.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final bool isOrderSuccess;
  final String paymentMethod; // 'Cash' or 'Online'

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.isOrderSuccess = false,
    this.paymentMethod = 'Cash',
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  int getItemQuantity(MenuItem item) {
    final found = items.where((i) => i.menuItem.id == item.id);
    return found.isEmpty ? 0 : found.first.quantity;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    bool? isOrderSuccess,
    String? paymentMethod,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOrderSuccess: isOrderSuccess ?? this.isOrderSuccess,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  late final ApiService _apiService;

  @override
  CartState build() {
    _apiService = ref.read(apiServiceProvider);
    return CartState();
  }

  void addToCart(MenuItem item) {
    // Check if item already exists
    final index = state.items.indexWhere((i) => i.menuItem.id == item.id);
    List<CartItem> newItems;

    if (index >= 0) {
      // Update quantity
      newItems = List.from(state.items);
      newItems[index].quantity++;
    } else {
      // Add new
      newItems = [...state.items, CartItem(menuItem: item)];
    }
    state = state.copyWith(items: newItems, isOrderSuccess: false);
  }

  void removeFromCart(MenuItem item) {
    final index = state.items.indexWhere((i) => i.menuItem.id == item.id);
    if (index >= 0) {
      List<CartItem> newItems = List.from(state.items);
      if (newItems[index].quantity > 1) {
        newItems[index].quantity--;
      } else {
        newItems.removeAt(index);
      }
      state = state.copyWith(items: newItems);
    }
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void clearCart() {
    state = CartState();
  }

  Future<void> placeOrder(String? notes) async {
    final authState = ref.read(authProvider);
    final guest = authState.guest;

    if (guest == null) {
      state = state.copyWith(error: 'Guest not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, isOrderSuccess: false);

    try {
      final itemsPayload = state.items
          .map((i) => {'menuItemId': i.menuItem.id, 'quantity': i.quantity})
          .toList();

      await _apiService.post(
        ApiConstants.orders,
        data: {
          'roomNumber': guest.roomNumber,
          'items': itemsPayload,
          'notes': notes,
          'paymentMethod': state.paymentMethod,
        },
      );

      // Success
      state = CartState(isOrderSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
