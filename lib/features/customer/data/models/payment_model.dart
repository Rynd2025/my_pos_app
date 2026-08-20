import 'package:hive/hive.dart';
import '../../domain/entities/payment.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 5)
class PaymentModel extends Payment {
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
  final int amountMillimes;
  @override
  @HiveField(4)
  final DateTime createdAt;
  @override
  @HiveField(5)
  final String paymentMethod;
  @override
  @HiveField(6)
  final String? note;

  PaymentModel({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.amountMillimes,
    required this.createdAt,
    required this.paymentMethod,
    this.note,
  }) : super(
          id: id,
          customerId: customerId,
          saleId: saleId,
          amountMillimes: amountMillimes,
          createdAt: createdAt,
          paymentMethod: paymentMethod,
          note: note,
        );

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      customerId: payment.customerId,
      saleId: payment.saleId,
      amountMillimes: payment.amountMillimes,
      createdAt: payment.createdAt,
      paymentMethod: payment.paymentMethod,
      note: payment.note,
    );
  }

  Payment toEntity() {
    return Payment(
      id: id,
      customerId: customerId,
      saleId: saleId,
      amountMillimes: amountMillimes,
      createdAt: createdAt,
      paymentMethod: paymentMethod,
      note: note,
    );
  }
}
