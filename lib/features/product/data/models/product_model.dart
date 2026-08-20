import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ProductModel extends Product {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String? barcode;
  @override
  @HiveField(3)
  final double price;
  @override
  @HiveField(4)
  final int stock;
  @override
  @HiveField(5)
  final String? brand;
  @override
  @HiveField(6)
  final String? category;
  @override
  @HiveField(7)
  final String? unit;
  @override
  @HiveField(9)
  final double purchasePrice;
  @override
  @HiveField(10)
  final int? lowStockThreshold;
  @override
  @HiveField(11)
  final DateTime? updatedAt;
  @override
  @HiveField(12)
  final bool isDeleted;

  ProductModel({
    required this.id,
    required this.name,
    this.barcode,
    required this.price,
    this.purchasePrice = 0.0,
    required this.stock,
    this.lowStockThreshold,
    this.brand,
    this.category,
    this.unit,
    this.updatedAt,
    this.isDeleted = false,
  }) : super(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          purchasePrice: purchasePrice,
          stock: stock,
          lowStockThreshold: lowStockThreshold,
          brand: brand,
          category: category,
          unit: unit,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
        );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      purchasePrice: product.purchasePrice,
      stock: product.stock,
      lowStockThreshold: product.lowStockThreshold,
      brand: product.brand,
      category: product.category,
      unit: product.unit,
      updatedAt: product.updatedAt,
      isDeleted: product.isDeleted,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      purchasePrice: purchasePrice,
      stock: stock,
      lowStockThreshold: lowStockThreshold,
      brand: brand,
      category: category,
      unit: unit,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
