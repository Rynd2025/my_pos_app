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
  final DateTime? updatedAt;
  final bool isDeleted;

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
    this.updatedAt,
    this.isDeleted = false,
  });

  Sale copyWith({
    String? id,
    String? ticketNumber,
    DateTime? createdAt,
    String? customerId,
    List<SaleItem>? items,
    int? totalMillimes,
    int? paidMillimes,
    int? dueMillimes,
    PaymentMethod? paymentMethod,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Sale(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      createdAt: createdAt ?? this.createdAt,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      totalMillimes: totalMillimes ?? this.totalMillimes,
      paidMillimes: paidMillimes ?? this.paidMillimes,
      dueMillimes: dueMillimes ?? this.dueMillimes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

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
        paymentMethod,
        updatedAt,
        isDeleted,
      ];
}

class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String? productId;
  final String productName;
  final int quantity;
  final int priceAtSaleMillimes; // Selling price at time of sale
  final int purchasePriceAtSaleMillimes; // Buy price at time of sale
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const SaleItem({
    required this.id,
    required this.saleId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtSaleMillimes,
    required this.purchasePriceAtSaleMillimes,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  int get totalMillimes => quantity * priceAtSaleMillimes;
  int get profitMillimes => (priceAtSaleMillimes - purchasePriceAtSaleMillimes) * quantity;

  @override
  List<Object?> get props => [
        id,
        saleId,
        productId,
        productName,
        quantity,
        priceAtSaleMillimes,
        purchasePriceAtSaleMillimes,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}
