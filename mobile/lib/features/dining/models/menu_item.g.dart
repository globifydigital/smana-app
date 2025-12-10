// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['_id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  allergens: (json['allergens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'category': instance.category,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'allergens': instance.allergens,
  'isActive': instance.isActive,
};
