import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
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
  @override
  @HiveField(7)
  final DateTime? updatedAt;
  @override
  @HiveField(8)
  final bool isDeleted;

  PaymentModel({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.amountMillimes,
    required this.createdAt,
    required this.paymentMethod,
    this.note,
    this.updatedAt,
    this.isDeleted = false,
  }) : super(
          id: id,
          customerId: customerId,
          saleId: saleId,
          amountMillimes: amountMillimes,
          createdAt: createdAt,
          paymentMethod: paymentMethod,
          note: note,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
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
      updatedAt: payment.updatedAt,
      isDeleted: payment.isDeleted,
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
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}
