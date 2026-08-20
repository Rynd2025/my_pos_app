import 'package:hive/hive.dart';
import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 4)
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

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    required this.balanceMillimes,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          balanceMillimes: balanceMillimes,
        );

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      balanceMillimes: customer.balanceMillimes,
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      balanceMillimes: balanceMillimes,
    );
  }
}
