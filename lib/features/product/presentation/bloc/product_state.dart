part of 'product_bloc.dart';

enum ProductStatus { initial, loading, loaded, error, success }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final String? message;
  final double importProgress;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.message,
    this.importProgress = 0,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? message,
    double? importProgress,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      message: message,
      importProgress: importProgress ?? this.importProgress,
    );
  }

  @override
  List<Object?> get props => [status, products, message, importProgress];
}
