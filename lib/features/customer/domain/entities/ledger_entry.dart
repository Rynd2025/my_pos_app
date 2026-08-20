import 'package:equatable/equatable.dart';

enum LedgerEntryType { creditSale, payment, adjustment }

class LedgerEntry extends Equatable {
  final String id;
  final String? paymentId; // Traceable financial ID
  final String customerId;
  final String? saleId;
  final String? ticketNumber;
  final LedgerEntryType type;
  final int amountMillimes; // Positive = debt increased, Negative = debt decreased
  final DateTime createdAt;
  final String? note;
  final int balanceAfter; // Balance snapshot after this transaction
  final DateTime? updatedAt;
  final bool isDeleted;

  const LedgerEntry({
    required this.id,
    this.paymentId,
    required this.customerId,
    this.saleId,
    this.ticketNumber,
    required this.type,
    required this.amountMillimes,
    required this.createdAt,
    this.note,
    required this.balanceAfter,
    this.updatedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        paymentId,
        customerId,
        saleId,
        ticketNumber,
        type,
        amountMillimes,
        createdAt,
        note,
        balanceAfter,
        updatedAt,
        isDeleted,
      ];
}
