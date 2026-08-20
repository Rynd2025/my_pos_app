import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String addressLine1;
  @override
  @HiveField(3)
  final String addressLine2;
  @override
  @HiveField(4)
  final String phoneNumber;
  @override
  @HiveField(5)
  final String upiId;
  @override
  @HiveField(6)
  final String footerText;
  @override
  @HiveField(7)
  final DateTime? updatedAt;
  @override
  @HiveField(8)
  final bool isDeleted;

  const ShopModel({
    required this.id,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.upiId,
    required this.footerText,
    this.updatedAt,
    this.isDeleted = false,
  }) : super(
          id: id,
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          upiId: upiId,
          footerText: footerText,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      id: shop.id,
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
      updatedAt: shop.updatedAt,
      isDeleted: shop.isDeleted,
    );
  }

  Shop toEntity() {
    return Shop(
      id: id,
      name: name,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      phoneNumber: phoneNumber,
      upiId: upiId,
      footerText: footerText,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) => _$ShopModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShopModelToJson(this);
}
