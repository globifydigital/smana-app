import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/food_order.dart';
import '../../auth/providers/auth_provider.dart';

class OrderState {
  final List<FoodOrder> orders;
  final List<FoodOrder> currentOrders;
  final List<FoodOrder> previousOrders;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    List<FoodOrder>? currentOrders,
    List<FoodOrder>? previousOrders,
    this.isLoading = false,
    this.error,
  }) : currentOrders = currentOrders ?? _filterCurrentOrders(orders),
       previousOrders = previousOrders ?? _filterPreviousOrders(orders);

  static List<FoodOrder> _filterCurrentOrders(List<FoodOrder> orders) {
    return orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'pending' ||
          status == 'preparing' ||
          status == 'ready' ||
          status == 'confirmed';
    }).toList();
  }

  static List<FoodOrder> _filterPreviousOrders(List<FoodOrder> orders) {
    return orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'completed' || status == 'cancelled';
    }).toList();
  }

  OrderState copyWith({
    List<FoodOrder>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  late final ApiService _apiService;
  late final SocketService _socketService;

  @override
  OrderState build() {
    _apiService = ref.read(apiServiceProvider);
    _socketService = ref.read(socketServiceProvider);
    _setupSocketListeners();
    // Auto fetch using microtask to avoid reading state during build
    Future.microtask(() => fetchOrders());
    return OrderState(isLoading: true);
  }

  void _setupSocketListeners() {
    _socketService.on('order-status-changed', (data) {
      if (data != null && data is Map<String, dynamic>) {
        final updatedOrder = FoodOrder.fromJson(data);
        final index = state.orders.indexWhere((o) => o.id == updatedOrder.id);
        if (index >= 0) {
          final updatedOrders = List<FoodOrder>.from(state.orders);
          updatedOrders[index] = updatedOrder;
          state = state.copyWith(orders: updatedOrders);
        }
      }
    });

    // Also listen for new orders if I placed one from another device?
    // Usually 'new-food-order' is broadcast to admins. Does guest get it?
    // Usually the placeOrder response adds it to local state in CartProvider (wait cart doesn't store history).
    // If we place an order, we should probably refresh this list or append to it.
    // Ideally we should listen to a 'new-order-for-guest' event or just refetch.
  }

  Future<void> fetchOrders() async {
    print('OrderNotifier: fetchOrders called');
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('OrderNotifier: calling API ${ApiConstants.myOrders}');
      final response = await _apiService.get(ApiConstants.myOrders);
      print('OrderNotifier: API response ${response.statusCode}');
      final List<dynamic> data = response.data;
      final orders = data.map((json) => FoodOrder.fromJson(json)).toList();
      print('OrderNotifier: parsed ${orders.length} orders');
      state = OrderState(orders: orders, isLoading: false);
    } catch (e, stack) {
      print('OrderNotifier: Error $e');
      print(stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addOrder(FoodOrder order) {
    state = state.copyWith(orders: [order, ...state.orders]);
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() {
  return OrderNotifier();
});
