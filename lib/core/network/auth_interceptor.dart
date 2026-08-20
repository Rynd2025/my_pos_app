import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../service_locator.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({required this.secureStorage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        final authRepo = sl<AuthRepository>();
        final result = await authRepo.refreshTokens(refreshToken);
        
        if (result.isRight()) {
          final newAccessToken = (result as dynamic).value.accessToken;
          // Retry request
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final dio = Dio(BaseOptions(baseUrl: options.baseUrl)); // Simple dio for retry
          final response = await dio.fetch(options);
          return handler.resolve(response);
        }
      }
    }
    return handler.next(err);
  }
}
