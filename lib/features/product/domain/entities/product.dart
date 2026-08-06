import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final String category;
  final String image;
  final String description;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.category = 'General',
    this.image = '',
    this.description = '',
    this.stock = 0,
  });

  @override
  List<Object?> get props =>
      [id, name, barcode, price, category, image, description, stock];
}
