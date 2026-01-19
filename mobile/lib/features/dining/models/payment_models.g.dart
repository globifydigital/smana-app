// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingAddress _$BillingAddressFromJson(Map<String, dynamic> json) =>
    BillingAddress(
      givenName: json['givenName'] as String,
      surname: json['surname'] as String,
      street1: json['street1'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postcode: json['postcode'] as String,
    );

Map<String, dynamic> _$BillingAddressToJson(BillingAddress instance) =>
    <String, dynamic>{
      'givenName': instance.givenName,
      'surname': instance.surname,
      'street1': instance.street1,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postcode': instance.postcode,
    };

CheckoutRequest _$CheckoutRequestFromJson(Map<String, dynamic> json) =>
    CheckoutRequest(
      orderId: json['orderId'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String? ?? 'AED',
      customerEmail: json['customerEmail'] as String,
      billingAddress: BillingAddress.fromJson(
        json['billingAddress'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CheckoutRequestToJson(CheckoutRequest instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'customerEmail': instance.customerEmail,
      'billingAddress': instance.billingAddress,
    };

CheckoutResponse _$CheckoutResponseFromJson(Map<String, dynamic> json) =>
    CheckoutResponse(
      success: json['success'] as bool,
      checkoutId: json['checkoutId'] as String,
      integrity: json['integrity'] as String?,
      result: ResultInfo.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheckoutResponseToJson(CheckoutResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'checkoutId': instance.checkoutId,
      'integrity': instance.integrity,
      'result': instance.result,
    };

ResultInfo _$ResultInfoFromJson(Map<String, dynamic> json) => ResultInfo(
  code: json['code'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$ResultInfoToJson(ResultInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
    };

PaymentStatusResponse _$PaymentStatusResponseFromJson(
  Map<String, dynamic> json,
) => PaymentStatusResponse(
  success: json['success'] as bool,
  pending: json['pending'] as bool,
  paymentStatus: json['paymentStatus'] as String,
  result: ResultInfo.fromJson(json['result'] as Map<String, dynamic>),
  transactionId: json['transactionId'] as String?,
  paymentBrand: json['paymentBrand'] as String?,
  amount: json['amount'] as String?,
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$PaymentStatusResponseToJson(
  PaymentStatusResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'pending': instance.pending,
  'paymentStatus': instance.paymentStatus,
  'result': instance.result,
  'transactionId': instance.transactionId,
  'paymentBrand': instance.paymentBrand,
  'amount': instance.amount,
  'currency': instance.currency,
};
