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
  final DateTime dateTime;
  
  @override
  @HiveField(2)
  final List<SaleItemModel> items;
  
  @override
  @HiveField(3)
  final double totalAmount;

  const SaleModel({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.totalAmount,
  }) : super(
          id: id,
          dateTime: dateTime,
          items: items,
          totalAmount: totalAmount,
        );

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      dateTime: sale.dateTime,
      items: sale.items.map((i) => SaleItemModel.fromEntity(i)).toList(),
      totalAmount: sale.totalAmount,
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      dateTime: dateTime,
      items: items.map((i) => i.toEntity()).toList(),
      totalAmount: totalAmount,
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
  final double price;
  
  @override
  @HiveField(3)
  final int quantity;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  }) : super(
          productId: productId,
          productName: productName,
          price: price,
          quantity: quantity,
        );

  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
    );
  }

  SaleItem toEntity() {
    return SaleItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
    );
  }
}
