import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final int balanceMillimes; // Positive means debt
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.balanceMillimes = 0,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    int? balanceMillimes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balanceMillimes: balanceMillimes ?? this.balanceMillimes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, balanceMillimes, createdAt, updatedAt, isDeleted];
}
