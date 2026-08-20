import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String customerId;
  final String? saleId;
  final int amountMillimes;
  final DateTime createdAt;
  final String paymentMethod; // e.g., "ESPÈCES"
  final String? note;

  const Payment({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.amountMillimes,
    required this.createdAt,
    this.paymentMethod = 'ESPÈCES',
    this.note,
  });

  @override
  List<Object?> get props => [id, customerId, saleId, amountMillimes, createdAt, paymentMethod, note];
}
