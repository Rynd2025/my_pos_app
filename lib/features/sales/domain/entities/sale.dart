import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final DateTime dateTime;
  final List<SaleItem> items;
  final double totalAmount;

  const Sale({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [id, dateTime, items, totalAmount];
}

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, productName, price, quantity];
}
