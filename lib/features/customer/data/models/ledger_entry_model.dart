import 'package:hive/hive.dart';
import '../../domain/entities/ledger_entry.dart';

part 'ledger_entry_model.g.dart';

@HiveType(typeId: 6)
class LedgerEntryModel extends LedgerEntry {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String customerId;
  @override
  @HiveField(2)
  final String? saleId;
  @override
  @HiveField(3)
  final int typeIndex;
  @override
  @HiveField(4)
  final int amountMillimes;
  @override
  @HiveField(5)
  final DateTime createdAt;
  @override
  @HiveField(6)
  final String? note;
  @override
  @HiveField(7)
  final String paymentId;
  @override
  @HiveField(8)
  final String? ticketNumber;
  @override
  @HiveField(9)
  final int balanceAfter;

  LedgerEntryModel({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.typeIndex,
    required this.amountMillimes,
    required this.createdAt,
    this.note,
    required this.paymentId,
    this.ticketNumber,
    required this.balanceAfter,
  }) : super(
          id: id,
          customerId: customerId,
          saleId: saleId,
          type: LedgerEntryType.values[typeIndex],
          amountMillimes: amountMillimes,
          createdAt: createdAt,
          note: note,
          paymentId: paymentId,
          ticketNumber: ticketNumber,
          balanceAfter: balanceAfter,
        );

  factory LedgerEntryModel.fromEntity(LedgerEntry entry) {
    return LedgerEntryModel(
      id: entry.id,
      customerId: entry.customerId,
      saleId: entry.saleId,
      typeIndex: entry.type.index,
      amountMillimes: entry.amountMillimes,
      createdAt: entry.createdAt,
      note: entry.note,
      paymentId: entry.paymentId,
      ticketNumber: entry.ticketNumber,
      balanceAfter: entry.balanceAfter,
    );
  }

  LedgerEntry toEntity() {
    return LedgerEntry(
      id: id,
      paymentId: paymentId,
      customerId: customerId,
      saleId: saleId,
      ticketNumber: ticketNumber,
      type: LedgerEntryType.values[typeIndex],
      amountMillimes: amountMillimes,
      createdAt: createdAt,
      note: note,
      balanceAfter: balanceAfter,
    );
  }
}
