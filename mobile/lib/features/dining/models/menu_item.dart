import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItem {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final double price;
  final String category;
  final String? description;
  final String? imageUrl;
  final List<String>? allergens;
  final bool isActive;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description,
    this.imageUrl,
    this.allergens,
    this.isActive = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
