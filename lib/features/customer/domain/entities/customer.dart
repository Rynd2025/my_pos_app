import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final int balanceMillimes; // Positive means debt

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.balanceMillimes = 0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    int? balanceMillimes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balanceMillimes: balanceMillimes ?? this.balanceMillimes,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, balanceMillimes];
}
