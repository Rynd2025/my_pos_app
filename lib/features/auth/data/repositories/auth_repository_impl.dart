import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/data/hive_database.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

const _cachedUserKey = 'cached_user';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AuthTokens>> login(String username, String password) async {
    try {
      final deviceIdResult = await getDeviceIdentifier();
      final id = deviceIdResult.getOrElse((_) => const Uuid().v4());
      
      final deviceName = Platform.isAndroid ? "Android Device" : "iOS Device";

      final tokens = await remoteDataSource.login(username, password, id, deviceName);
      
      await secureStorage.write(key: 'access_token', value: tokens.accessToken);
      await secureStorage.write(key: 'refresh_token', value: tokens.refreshToken);
      
      return Right(tokens);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshTokens(String refreshToken) async {
    try {
      final tokens = await remoteDataSource.refreshTokens(refreshToken);
      await secureStorage.write(key: 'access_token', value: tokens.accessToken);
      await secureStorage.write(key: 'refresh_token', value: tokens.refreshToken);
      return Right(tokens);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await HiveDatabase.settingsBox.delete(_cachedUserKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    // No stored session at all — genuinely logged out, not just offline.
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      return const Right(null);
    }

    try {
      final user = await remoteDataSource.getMe();
      if (user != null) await _cacheUser(user);
      return Right(user);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        // Server explicitly rejected the session/device (already tried a
        // refresh via the interceptor) — this is a real logout, not a
        // connectivity blip.
        await logout();
        return const Right(null);
      }
      // No response at all (offline, timeout, DNS failure, etc.) — this is
      // an offline-first app, so a network hiccup must never log the user
      // out. Fall back to the last known session.
      return Right(await _readCachedUser());
    } catch (_) {
      return Right(await _readCachedUser());
    }
  }

  Future<void> _cacheUser(UserModel user) async {
    await HiveDatabase.settingsBox.put(_cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<User?> _readCachedUser() async {
    final raw = HiveDatabase.settingsBox.get(_cachedUserKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, String>> getDeviceIdentifier() async {
    try {
      String? deviceId = HiveDatabase.settingsBox.get('device_id');
      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await HiveDatabase.settingsBox.put('device_id', deviceId);
      }
      return Right(deviceId!);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
