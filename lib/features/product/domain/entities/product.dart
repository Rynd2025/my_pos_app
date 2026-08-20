import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? barcode;
  final double price; // This is the selling price
  final double purchasePrice; // Buy price
  final int stock;
  final int? lowStockThreshold;
  final String? brand;
  final String? category;
  final String? unit;
  final DateTime? updatedAt;
  final bool isDeleted;

  const Product({
    required this.id,
    required this.name,
    this.barcode,
    required this.price,
    this.purchasePrice = 0.0,
    this.stock = 0,
    this.lowStockThreshold,
    this.brand,
    this.category,
    this.unit,
    this.updatedAt,
    this.isDeleted = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    double? purchasePrice,
    int? stock,
    int? lowStockThreshold,
    String? brand,
    String? category,
    String? unit,
    DateTime? updatedAt,
    bool? isDeleted,
    bool clearBarcode = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      price: price ?? this.price,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        price,
        purchasePrice,
        stock,
        lowStockThreshold,
        brand,
        category,
        unit,
        updatedAt,
        isDeleted,
      ];
}
