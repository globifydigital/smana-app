// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestModel _$GuestModelFromJson(Map<String, dynamic> json) => GuestModel(
  id: json['_id'] as String?,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  isCheckedIn: json['isCheckedIn'] as bool,
  roomNumber: json['roomNumber'] as String?,
  checkInDate: json['checkInDate'] == null
      ? null
      : DateTime.parse(json['checkInDate'] as String),
  checkOutDate: json['checkOutDate'] == null
      ? null
      : DateTime.parse(json['checkOutDate'] as String),
);

Map<String, dynamic> _$GuestModelToJson(GuestModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'isCheckedIn': instance.isCheckedIn,
      'roomNumber': instance.roomNumber,
      'checkInDate': instance.checkInDate?.toIso8601String(),
      'checkOutDate': instance.checkOutDate?.toIso8601String(),
    };
