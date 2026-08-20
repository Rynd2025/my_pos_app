import 'package:equatable/equatable.dart';

enum PaymentMethod { cash, credit }

class Sale extends Equatable {
  final String id;
  final String ticketNumber; // e.g., #000241
  final DateTime createdAt;
  final String? customerId;
  final List<SaleItem> items;
  final int totalMillimes;
  final int paidMillimes;
  final int dueMillimes;
  final PaymentMethod paymentMethod;

  const Sale({
    required this.id,
    required this.ticketNumber,
    required this.createdAt,
    this.customerId,
    required this.items,
    required this.totalMillimes,
    required this.paidMillimes,
    required this.dueMillimes,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        createdAt,
        customerId,
        items,
        totalMillimes,
        paidMillimes,
        dueMillimes,
        paymentMethod
      ];
}

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final int priceMillimes; // Selling price at time of sale
  final int purchasePriceMillimes; // Buy price at time of sale

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceMillimes,
    required this.purchasePriceMillimes,
  });

  int get totalMillimes => quantity * priceMillimes;
  int get profitMillimes => (priceMillimes - purchasePriceMillimes) * quantity;

  @override
  List<Object?> get props =>
      [productId, productName, quantity, priceMillimes, purchasePriceMillimes];
}
