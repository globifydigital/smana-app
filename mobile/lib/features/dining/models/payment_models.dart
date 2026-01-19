import 'package:json_annotation/json_annotation.dart';

part 'payment_models.g.dart';

// Billing Address Model
@JsonSerializable()
class BillingAddress {
  final String givenName;
  final String surname;
  final String street1;
  final String city;
  final String state;
  final String country;
  final String postcode;

  BillingAddress({
    required this.givenName,
    required this.surname,
    required this.street1,
    required this.city,
    required this.state,
    required this.country,
    required this.postcode,
  });

  factory BillingAddress.fromJson(Map<String, dynamic> json) =>
      _$BillingAddressFromJson(json);

  Map<String, dynamic> toJson() => _$BillingAddressToJson(this);
}

// Checkout Request Model
@JsonSerializable()
class CheckoutRequest {
  final String orderId;
  final String amount;
  final String currency;
  final String customerEmail;
  final BillingAddress billingAddress;

  CheckoutRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'AED',
    required this.customerEmail,
    required this.billingAddress,
  });

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutRequestToJson(this);
}

// Checkout Response Model
@JsonSerializable()
class CheckoutResponse {
  final bool success;
  final String checkoutId;
  final String? integrity; // PCI DSS v4.0
  final ResultInfo result;

  CheckoutResponse({
    required this.success,
    required this.checkoutId,
    this.integrity,
    required this.result,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutResponseToJson(this);
}

// Result Info Model
@JsonSerializable()
class ResultInfo {
  final String code;
  final String description;

  ResultInfo({required this.code, required this.description});

  factory ResultInfo.fromJson(Map<String, dynamic> json) =>
      _$ResultInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ResultInfoToJson(this);
}

// Payment Status Response Model
@JsonSerializable()
class PaymentStatusResponse {
  final bool success;
  final bool pending;
  final String paymentStatus;
  final ResultInfo result;
  final String? transactionId;
  final String? paymentBrand;
  final String? amount;
  final String? currency;

  PaymentStatusResponse({
    required this.success,
    required this.pending,
    required this.paymentStatus,
    required this.result,
    this.transactionId,
    this.paymentBrand,
    this.amount,
    this.currency,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusResponseToJson(this);
}
