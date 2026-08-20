import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/data/hive_database.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

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
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getMe();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
