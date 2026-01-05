import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';
import '../../features/dining/models/payment_models.dart';

class PaymentService {
  final Dio _dio;
  final SecureStorageService _storage;

  PaymentService({Dio? dio, SecureStorageService? storage})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)),
      _storage = storage ?? SecureStorageService();

  /// Create a checkout session with HyperPay
  Future<CheckoutResponse> createCheckout(CheckoutRequest request) async {
    try {
      // Get token
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.post(
        ApiConstants.paymentCheckout,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return CheckoutResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create checkout session',
      );
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create a checkout session with cart items (payment-first flow)
  Future<Map<String, dynamic>> createCheckoutWithItems({
    required List<Map<String, dynamic>> items,
    required String roomNumber,
    String? notes,
    required String currency,
    required String customerEmail,
    required BillingAddress billingAddress,
  }) async {
    try {
      // Get token
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.post(
        ApiConstants.paymentCheckout,
        data: {
          'items': items,
          'roomNumber': roomNumber,
          'notes': notes,
          'currency': currency,
          'customerEmail': customerEmail,
          'billingAddress': billingAddress.toJson(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create checkout session',
      );
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get payment status by checkout ID
  Future<PaymentStatusResponse> getPaymentStatus(String checkoutId) async {
    try {
      // Get token
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.get(
        '${ApiConstants.paymentStatus}/$checkoutId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return PaymentStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get payment status',
      );
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
