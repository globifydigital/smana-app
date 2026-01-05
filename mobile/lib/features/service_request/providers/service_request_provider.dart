import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/socket_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:dio/dio.dart';

// Model
class ServiceRequest {
  final String id;
  final String type;
  final String status;
  final String priority;
  final String message;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.message,
    required this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['_id'],
      type: json['type'],
      status: json['status'],
      priority: json['priority'],
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// State
class ServiceRequestState {
  final bool isLoading;
  final List<ServiceRequest> requests;
  final String? error;

  ServiceRequestState({
    this.isLoading = false,
    this.requests = const [],
    this.error,
  });

  ServiceRequestState copyWith({
    bool? isLoading,
    List<ServiceRequest>? requests,
    String? error,
  }) {
    return ServiceRequestState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      error: error ?? this.error,
    );
  }
}

// Provider
final serviceRequestProvider =
    NotifierProvider<ServiceRequestNotifier, ServiceRequestState>(() {
      return ServiceRequestNotifier();
    });

class ServiceRequestNotifier extends Notifier<ServiceRequestState> {
  late final SocketService _socketService;
  final Dio _dio = Dio();

  @override
  ServiceRequestState build() {
    _socketService = SocketService();
    // Ideally use ref.read(socketServiceProvider) if it exists, but reusing logic from AuthProvider:
    // AuthProvider uses ref.read(socketServiceProvider).
    // Let's assume socketServiceProvider is globally available or we get it from there.
    // Actually, let's look at AuthProvider again. It uses `ref.read(socketServiceProvider)`.
    // We can do the same here.

    // BUT, I need to know where socketServiceProvider is defined.
    // It was at the bottom of auth_provider.dart.
    // I should probably move it to a common place or import it.
    // Since I can't easily move it right now without editing auth_provider again,
    // I will try to use the Singleton `SocketService()` directly as defined in socket_service.dart lines 8-9.

    _initSocketListeners();

    // Cleanup
    ref.onDispose(() {
      _socketService.off('new-service-request');
      _socketService.off('request-status-updated');
    });

    // Initial fetch
    Future.microtask(() => fetchRequests());

    return ServiceRequestState();
  }

  void _initSocketListeners() {
    _socketService.on('new-service-request', (data) {
      // Check if this request belongs to current user
      final currentUser = ref.read(authProvider).guest;
      if (currentUser != null && data['guestId'] == currentUser.id) {
        final newRequest = ServiceRequest.fromJson(data);
        state = state.copyWith(requests: [newRequest, ...state.requests]);
      }
    });

    _socketService.on('request-status-updated', (data) {
      // Update local status
      final updatedList = state.requests.map((req) {
        if (req.id == data['_id']) {
          return ServiceRequest.fromJson(data);
        }
        return req;
      }).toList();
      state = state.copyWith(requests: updatedList);
    });
  }

  Future<void> fetchRequests() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = ref.read(authProvider).token;
      if (token == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/service-requests',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<ServiceRequest> loaded = (response.data as List)
          .map((e) => ServiceRequest.fromJson(e))
          .toList();

      state = state.copyWith(isLoading: false, requests: loaded);
    } catch (e) {
      // If 401, maybe token expired.
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createRequest(
    String type,
    String message,
    String priority,
  ) async {
    try {
      final token = ref.read(authProvider).token;
      final guest = ref.read(authProvider).guest;

      if (guest == null || token == null) return false;

      // Map frontend priority to backend enum (Low, Medium, High)
      String backendPriority = 'Medium';
      if (priority == 'Urgent') {
        backendPriority = 'High';
      } else if (priority == 'High')
        backendPriority = 'High';
      else if (priority == 'Normal')
        backendPriority = 'Medium';
      else if (priority == 'Low')
        backendPriority = 'Low';

      await _dio.post(
        '${ApiConstants.baseUrl}/service-requests',
        data: {
          'type': type,
          'message': message,
          'priority': backendPriority,
          'roomNumber': guest.roomNumber,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } catch (e) {
      print('Create Request Error: $e');
      return false;
    }
  }
}
