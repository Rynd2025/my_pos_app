import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
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
  @override
  @HiveField(9)
  final DateTime? updatedAt;
  @override
  @HiveField(10)
  final bool isDeleted;

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
    this.updatedAt,
    this.isDeleted = false,
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
          updatedAt: updatedAt,
          isDeleted: isDeleted,
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
      updatedAt: sale.updatedAt,
      isDeleted: sale.isDeleted,
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
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) => _$SaleModelFromJson(json);
  Map<String, dynamic> toJson() => _$SaleModelToJson(this);
}

@HiveType(typeId: 3)
@JsonSerializable()
class SaleItemModel extends SaleItem {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String saleId;
  @override
  @HiveField(2)
  final String? productId;
  @override
  @HiveField(3)
  final String productName;
  @override
  @HiveField(4)
  final int quantity;
  @override
  @HiveField(5)
  final int priceAtSaleMillimes;
  @override
  @HiveField(6)
  final int purchasePriceAtSaleMillimes;
  @override
  @HiveField(7)
  final DateTime createdAt;
  @override
  @HiveField(8)
  final DateTime? updatedAt;
  @override
  @HiveField(9)
  final bool isDeleted;

  SaleItemModel({
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
  }) : super(
          id: id,
          saleId: saleId,
          productId: productId,
          productName: productName,
          quantity: quantity,
          priceAtSaleMillimes: priceAtSaleMillimes,
          purchasePriceAtSaleMillimes: purchasePriceAtSaleMillimes,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
        );

  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      priceAtSaleMillimes: item.priceAtSaleMillimes,
      purchasePriceAtSaleMillimes: item.purchasePriceAtSaleMillimes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      isDeleted: item.isDeleted,
    );
  }

  SaleItem toEntity() {
    return SaleItem(
      id: id,
      saleId: saleId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      priceAtSaleMillimes: priceAtSaleMillimes,
      purchasePriceAtSaleMillimes: purchasePriceAtSaleMillimes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => _$SaleItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemModelToJson(this);
}
