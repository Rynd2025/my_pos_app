import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String customerId;
  final String? saleId;
  final int amountMillimes;
  final DateTime createdAt;
  final String paymentMethod; // e.g., "ESPÈCES"
  final String? note;
  final DateTime? updatedAt;
  final bool isDeleted;

  const Payment({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.amountMillimes,
    required this.createdAt,
    this.paymentMethod = 'ESPÈCES',
    this.note,
    this.updatedAt,
    this.isDeleted = false,
  });

  Payment copyWith({
    String? id,
    String? customerId,
    String? saleId,
    int? amountMillimes,
    DateTime? createdAt,
    String? paymentMethod,
    String? note,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      saleId: saleId ?? this.saleId,
      amountMillimes: amountMillimes ?? this.amountMillimes,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        saleId,
        amountMillimes,
        createdAt,
        paymentMethod,
        note,
        updatedAt,
        isDeleted,
      ];
}
