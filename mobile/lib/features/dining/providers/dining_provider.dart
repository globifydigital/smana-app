import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/menu_item.dart';
import '../../auth/providers/auth_provider.dart'; // For API/Socket services

class DiningState {
  final List<MenuItem> items;
  final bool isLoading;
  final String? error;
  final String selectedCategory;

  DiningState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'All',
  });

  DiningState copyWith({
    List<MenuItem>? items,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return DiningState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  // Helper to get filtered items
  List<MenuItem> get filteredItems {
    if (selectedCategory == 'All') return items;
    // Backend categories might be "Appetizer", "Main Course", "Dessert", "Beverage"
    // Frontend chips might map differently or directly.
    // Let's assume direct mapping for now, but handle "Starters" -> "Appetizer" mapping in UI or here.
    return items.where((item) => item.category == selectedCategory).toList();
  }
}

class DiningNotifier extends Notifier<DiningState> {
  late final ApiService _apiService;
  late final SocketService _socketService;

  @override
  DiningState build() {
    _apiService = ref.read(apiServiceProvider);
    _socketService = ref.read(socketServiceProvider);
    _fetchMenu();
    _setupSocketListeners();
    return DiningState(isLoading: true);
  }

  void _setupSocketListeners() {
    _socketService.on('menu-updated', (data) {
      // Data might be a full item or {id, deleted: true}
      if (data != null && data is Map<String, dynamic>) {
        if (data['deleted'] == true) {
          final id = data['id'];
          state = state.copyWith(
            items: state.items.where((i) => i.id != id).toList(),
          );
        } else {
          // New or Updated
          final newItem = MenuItem.fromJson(data);
          // Check if exists
          final index = state.items.indexWhere((i) => i.id == newItem.id);
          List<MenuItem> newItems;
          if (index >= 0) {
            newItems = List.from(state.items);
            newItems[index] = newItem;
          } else {
            newItems = [...state.items, newItem];
          }
          state = state.copyWith(items: newItems);
        }
      }
    });
  }

  Future<void> _fetchMenu() async {
    try {
      final response = await _apiService.get(
        ApiConstants.menu,
      ); // Ensure this constant exists or use string
      final List<dynamic> data = response.data;
      final items = data.map((json) => MenuItem.fromJson(json)).toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final diningProvider = NotifierProvider<DiningNotifier, DiningState>(() {
  return DiningNotifier();
});
