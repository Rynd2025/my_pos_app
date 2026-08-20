import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String shopId;
  final String username;
  final bool isDeviceAuthorized;

  const User({
    required this.id,
    required this.shopId,
    required this.username,
    required this.isDeviceAuthorized,
  });

  @override
  List<Object?> get props => [id, shopId, username, isDeviceAuthorized];
}
