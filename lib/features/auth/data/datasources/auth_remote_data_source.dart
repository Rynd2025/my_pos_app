import 'package:dio/dio.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login(String username, String password, String deviceId, String deviceName);
  Future<AuthTokensModel> refreshTokens(String refreshToken);
  Future<UserModel?> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthTokensModel> login(String username, String password, String deviceId, String deviceName) async {
    final response = await dio.post('/auth/login', data: {
      'username': username,
      'password': password,
      'device_id': deviceId,
      'device_name': deviceName,
    });
    return AuthTokensModel.fromJson(response.data);
  }

  @override
  Future<AuthTokensModel> refreshTokens(String refreshToken) async {
    final response = await dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return AuthTokensModel.fromJson(response.data);
  }

  @override
  Future<UserModel?> getMe() async {
    final response = await dio.get('/auth/me');
    if (response.data == null) return null;
    return UserModel.fromJson(response.data);
  }
}
