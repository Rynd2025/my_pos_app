import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.shopId,
    required super.username,
    required super.isDeviceAuthorized,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      shopId: json['shop_id'],
      username: json['username'],
      isDeviceAuthorized: json['is_device_authorized'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'username': username,
      'is_device_authorized': isDeviceAuthorized,
    };
  }
}
