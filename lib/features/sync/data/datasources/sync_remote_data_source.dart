import 'package:dio/dio.dart';

abstract class SyncRemoteDataSource {
  Future<void> pushOutbox(Map<String, dynamic> data);
  Future<Map<String, dynamic>> pullUpdates(int lastCursor);
  Future<Map<String, dynamic>> restoreShop();
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  final Dio dio;

  SyncRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> pushOutbox(Map<String, dynamic> data) async {
    await dio.post('/sync/push', data: data);
  }

  @override
  Future<Map<String, dynamic>> pullUpdates(int lastCursor) async {
    final response = await dio.get('/sync/pull', queryParameters: {'after': lastCursor});
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> restoreShop() async {
    final response = await dio.get('/sync/restore');
    return response.data;
  }
}
