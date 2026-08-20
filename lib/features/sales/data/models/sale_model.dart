import 'package:hive/hive.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class SaleModel extends Sale {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String ticketNumber;
  @override
  @HiveField(2)
  final DateTime createdAt;
  @override
  @HiveField(3)
  final String? customerId;
  @override
  @HiveField(4)
  final List<SaleItemModel> items;
  @override
  @HiveField(5)
  final int totalMillimes;
  @override
  @HiveField(6)
  final int paidMillimes;
  @override
  @HiveField(7)
  final int dueMillimes;
  @override
  @HiveField(8)
  final int paymentMethodIndex;

  SaleModel({
    required this.id,
    required this.ticketNumber,
    required this.createdAt,
    this.customerId,
    required this.items,
    required this.totalMillimes,
    required this.paidMillimes,
    required this.dueMillimes,
    required this.paymentMethodIndex,
  }) : super(
          id: id,
          ticketNumber: ticketNumber,
          createdAt: createdAt,
          customerId: customerId,
          items: items,
          totalMillimes: totalMillimes,
          paidMillimes: paidMillimes,
          dueMillimes: dueMillimes,
          paymentMethod: PaymentMethod.values[paymentMethodIndex],
        );

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      ticketNumber: sale.ticketNumber,
      createdAt: sale.createdAt,
      customerId: sale.customerId,
      items: sale.items.map((i) => SaleItemModel.fromEntity(i)).toList(),
      totalMillimes: sale.totalMillimes,
      paidMillimes: sale.paidMillimes,
      dueMillimes: sale.dueMillimes,
      paymentMethodIndex: sale.paymentMethod.index,
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      ticketNumber: ticketNumber,
      createdAt: createdAt,
      customerId: customerId,
      items: items.map((i) => i.toEntity()).toList(),
      totalMillimes: totalMillimes,
      paidMillimes: paidMillimes,
      dueMillimes: dueMillimes,
      paymentMethod: PaymentMethod.values[paymentMethodIndex],
    );
  }
}

@HiveType(typeId: 3)
class SaleItemModel extends SaleItem {
  @override
  @HiveField(0)
  final String productId;
  @override
  @HiveField(1)
  final String productName;
  @override
  @HiveField(2)
  final int quantity;
  @override
  @HiveField(3)
  final int priceMillimes;
  @override
  @HiveField(4)
  final int purchasePriceMillimes;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceMillimes,
    required this.purchasePriceMillimes,
  }) : super(
          productId: productId,
          productName: productName,
          quantity: quantity,
          priceMillimes: priceMillimes,
          purchasePriceMillimes: purchasePriceMillimes,
        );

  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      priceMillimes: item.priceMillimes,
      purchasePriceMillimes: item.purchasePriceMillimes,
    );
  }

  SaleItem toEntity() {
    return SaleItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      priceMillimes: priceMillimes,
      purchasePriceMillimes: purchasePriceMillimes,
    );
  }
}
