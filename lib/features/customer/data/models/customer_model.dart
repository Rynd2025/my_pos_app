import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class CustomerModel extends Customer {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String? phone;
  @override
  @HiveField(3)
  final int balanceMillimes;
  @override
  @HiveField(4)
  final DateTime createdAt;
  @override
  @HiveField(5)
  final DateTime? updatedAt;
  @override
  @HiveField(6)
  final bool isDeleted;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    required this.balanceMillimes,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          balanceMillimes: balanceMillimes,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
        );

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      balanceMillimes: customer.balanceMillimes,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      isDeleted: customer.isDeleted,
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      balanceMillimes: balanceMillimes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);
}
