part of 'shop_bloc.dart';

enum ShopStatus { initial, loading, loaded, success, error }

class ShopState extends Equatable {
  final ShopStatus status;
  final Shop shop;
  final String? message;

  const ShopState({
    this.status = ShopStatus.initial,
    this.shop = const Shop(),
    this.message,
  });

  @override
  List<Object?> get props => [status, shop, message];

  ShopState copyWith({
    ShopStatus? status,
    Shop? shop,
    String? message,
  }) {
    return ShopState(
      status: status ?? this.status,
      shop: shop ?? this.shop,
      message: message ?? this.message,
    );
  }
}
