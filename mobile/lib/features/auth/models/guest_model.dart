import 'package:json_annotation/json_annotation.dart';

part 'guest_model.g.dart';

@JsonSerializable()
class GuestModel {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final bool isCheckedIn;
  final String? roomNumber;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  GuestModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isCheckedIn,
    this.roomNumber,
    this.checkInDate,
    this.checkOutDate,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) =>
      _$GuestModelFromJson(json);
  Map<String, dynamic> toJson() => _$GuestModelToJson(this);

  GuestModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isCheckedIn,
    String? roomNumber,
    DateTime? checkInDate,
    DateTime? checkOutDate,
  }) {
    return GuestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      roomNumber: roomNumber ?? this.roomNumber,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
    );
  }
}
