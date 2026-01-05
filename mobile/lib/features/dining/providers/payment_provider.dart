import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_models.dart';
import '../../../core/services/payment_service.dart';

// Payment state
class PaymentState {
  final bool isLoading;
  final String? error;
  final CheckoutResponse? checkoutResponse;
  final PaymentStatusResponse? paymentStatus;

  const PaymentState({
    this.isLoading = false,
    this.error,
    this.checkoutResponse,
    this.paymentStatus,
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    CheckoutResponse? checkoutResponse,
    PaymentStatusResponse? paymentStatus,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      checkoutResponse: checkoutResponse ?? this.checkoutResponse,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

// Payment provider
class PaymentNotifier extends Notifier<PaymentState> {
  late final PaymentService _paymentService;

  @override
  PaymentState build() {
    _paymentService = ref.watch(paymentServiceProvider);
    return const PaymentState();
  }

  /// Create checkout session
  Future<String?> createCheckout(CheckoutRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.createCheckout(request);
      state = state.copyWith(isLoading: false, checkoutResponse: response);
      return response.checkoutId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Get payment status
  Future<PaymentStatusResponse?> getPaymentStatus(String checkoutId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.getPaymentStatus(checkoutId);
      state = state.copyWith(isLoading: false, paymentStatus: response);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Create checkout session with cart items
  Future<Map<String, dynamic>?> createCheckoutWithItems({
    required List<Map<String, dynamic>> items,
    required String roomNumber,
    String? notes,
    required String currency,
    required String customerEmail,
    required BillingAddress billingAddress,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.createCheckoutWithItems(
        items: items,
        roomNumber: roomNumber,
        notes: notes,
        currency: currency,
        customerEmail: customerEmail,
        billingAddress: billingAddress,
      );
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Reset state
  void reset() {
    state = const PaymentState();
  }
}

// Providers
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(() {
  return PaymentNotifier();
});
