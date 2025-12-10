import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/guest_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/secure_storage_service.dart';

// State holder
class AuthState {
  final GuestModel? guest;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({this.guest, this.token, this.isLoading = false, this.error});

  AuthState copyWith({
    GuestModel? guest,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      guest: guest ?? this.guest,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiService _apiService;
  late final SocketService _socketService;
  late final SecureStorageService _secureStorageService;

  @override
  AuthState build() {
    _apiService = ref.read(apiServiceProvider);
    _socketService = ref.read(socketServiceProvider);
    _secureStorageService = ref.read(secureStorageServiceProvider);
    _socketService.init();
    _setupSocketListeners();
    // Ideally check for existing token here and hydrate state
    return AuthState();
  }

  void _setupSocketListeners() {
    _socketService.on('guest-checked-in', (data) {
      if (state.guest != null && data['_id'] == state.guest!.id) {
        state = state.copyWith(guest: GuestModel.fromJson(data));
      }
    });

    _socketService.on('guest-checked-out', (data) {
      if (state.guest != null && data['_id'] == state.guest!.id) {
        state = state.copyWith(guest: GuestModel.fromJson(data));
      }
    });
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    state = AuthState(isLoading: true);
    try {
      print('Attempting register for $email');
      final response = await _apiService.post(
        ApiConstants.registerGuest,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      print('Register response: ${response.statusCode}');
      final guest = GuestModel.fromJson(response.data);
      final token = response.data['token'];
      if (token != null) {
        _apiService.setToken(token);
        await _secureStorageService.saveToken(token);
      }
      state = AuthState(guest: guest, token: token, isLoading: false);
      return true;
    } catch (e, stack) {
      print('Register error: $e');
      print(stack);
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      print('Attempting login for $email');
      final response = await _apiService.post(
        ApiConstants.loginGuest,
        data: {'email': email, 'password': password},
      );
      print('Login response: ${response.statusCode}');
      final guest = GuestModel.fromJson(response.data);
      final token = response.data['token']; // Capture token
      print('Guest parsed: ${guest.name}');
      if (token != null) {
        _apiService.setToken(token);
        await _secureStorageService.saveToken(token);
      }
      state = AuthState(guest: guest, token: token, isLoading: false);
      print('AuthNotifier: State updated. Returning true.');
      return true;
    } catch (e, stack) {
      print('Login error: $e');
      print(stack);
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    // 1. Clear JWT token from secure storage
    await _secureStorageService.deleteToken();

    // 2. Disconnect Socket.io
    _socketService.disconnect();
    // Note: socket.dispose() might prevent future connections if singleton isn't re-initialized.
    // Usually disconnect is enough for logout.

    // 3. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 4. Reset Provider State
    state = AuthState();

    // Note: Other providers should be invalidated by the UI layer (MainScaffold) calling ref.invalidate()
    // or listening to auth state changes.
  }
}

final apiServiceProvider = Provider((ref) => ApiService());
final socketServiceProvider = Provider((ref) => SocketService());
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
