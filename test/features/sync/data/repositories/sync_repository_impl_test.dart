// Covers the outbox push queue fix: one rejected/failed item must never
// block the items queued behind it, an item is only ever removed once the
// backend confirms success, and failures (permanent or transient) are kept
// around (never silently dropped) rather than deleted.
import 'dart:io';

import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/core/domain/entities/outbox.dart';
import 'package:billing_app/core/domain/repositories/outbox_repository.dart';
import 'package:billing_app/features/product/data/models/product_model.dart';
import 'package:billing_app/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:billing_app/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockOutboxRepository extends Mock implements OutboxRepository {}

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}

Outbox _outboxItem(String id, String entityId) {
  return Outbox(
    id: id,
    entityType: 'PRODUCT',
    entityId: entityId,
    operation: OutboxOperation.upsert,
    createdAt: DateTime(2026, 1, 1),
  );
}

DioException _rejected({int statusCode = 422}) => DioException(
      requestOptions: RequestOptions(path: '/sync/push'),
      response: Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: statusCode,
      ),
    );

DioException _transientNetworkFailure() => DioException(
      requestOptions: RequestOptions(path: '/sync/push'),
      type: DioExceptionType.connectionError,
    );

void main() {
  late Directory tempDir;
  late MockOutboxRepository outboxRepository;
  late MockSyncRemoteDataSource remoteDataSource;
  late SyncRepositoryImpl repository;

  setUpAll(() async {
    registerFallbackValue(<String, dynamic>{});

    // Hive's adapter registry is a process-wide singleton — register once
    // for the whole file rather than per-test, or a second test re-opening
    // the same typeId crashes with "already a TypeAdapter for typeId 0".
    tempDir = await Directory.systemTemp.createTemp('outbox_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ProductModelAdapter());
    await Hive.openBox<ProductModel>(HiveDatabase.productBoxName);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() {
    outboxRepository = MockOutboxRepository();
    remoteDataSource = MockSyncRemoteDataSource();
    repository = SyncRepositoryImpl(
      remoteDataSource: remoteDataSource,
      outboxRepository: outboxRepository,
    );

    when(() => outboxRepository.remove(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => outboxRepository.recordFailure(any(), any()))
        .thenAnswer((_) async => const Right(null));
  });

  tearDown(() async {
    await HiveDatabase.productBox.clear();
  });

  Future<void> putProduct(String id) async {
    await HiveDatabase.productBox.put(
      id,
      ProductModel(id: id, name: 'Test product $id', price: 1.0, stock: 1),
    );
  }

  test('a rejected item does not block items queued behind it', () async {
    await putProduct('a');
    await putProduct('b');
    await putProduct('c');

    final itemA = _outboxItem('outbox-a', 'a');
    final itemB = _outboxItem('outbox-b', 'b');
    final itemC = _outboxItem('outbox-c', 'c');

    when(() => outboxRepository.getAll())
        .thenAnswer((_) async => Right([itemA, itemB, itemC]));

    var attempts = 0;
    when(() => remoteDataSource.pushOutbox(any())).thenAnswer((invocation) async {
      attempts++;
      final body = invocation.positionalArguments.first as Map<String, dynamic>;
      if (body['entity_id'] == 'b') {
        throw _rejected();
      }
    });

    final result = await repository.pushOutbox();

    expect(result.isRight(), isTrue);
    // All three items were attempted — the middle rejection did not abort
    // the loop before item C was ever tried.
    expect(attempts, 3);

    verify(() => outboxRepository.remove('outbox-a')).called(1);
    verify(() => outboxRepository.remove('outbox-c')).called(1);
    verifyNever(() => outboxRepository.remove('outbox-b'));
    verify(() => outboxRepository.recordFailure('outbox-b', any())).called(1);
  });

  test('a transient network failure does not permanently kill the queue', () async {
    await putProduct('x');
    await putProduct('y');

    final itemX = _outboxItem('outbox-x', 'x');
    final itemY = _outboxItem('outbox-y', 'y');

    when(() => outboxRepository.getAll())
        .thenAnswer((_) async => Right([itemX, itemY]));

    when(() => remoteDataSource.pushOutbox(any())).thenAnswer((invocation) async {
      final body = invocation.positionalArguments.first as Map<String, dynamic>;
      if (body['entity_id'] == 'x') {
        throw _transientNetworkFailure();
      }
    });

    await repository.pushOutbox();

    verifyNever(() => outboxRepository.remove('outbox-x'));
    verify(() => outboxRepository.recordFailure('outbox-x', any())).called(1);
    verify(() => outboxRepository.remove('outbox-y')).called(1);
  });

  test('a successful item is only ever removed once, never pushed twice', () async {
    await putProduct('once');
    final item = _outboxItem('outbox-once', 'once');

    when(() => outboxRepository.getAll()).thenAnswer((_) async => Right([item]));
    when(() => remoteDataSource.pushOutbox(any())).thenAnswer((_) async {});

    await repository.pushOutbox();

    verify(() => remoteDataSource.pushOutbox(any())).called(1);
    verify(() => outboxRepository.remove('outbox-once')).called(1);
    verifyNever(() => outboxRepository.recordFailure(any(), any()));
  });

  test('repeated sync attempts do not corrupt the queue — a previously '
      'failed item can still succeed later, exactly once', () async {
    await putProduct('retry');
    final item = _outboxItem('outbox-retry', 'retry');

    when(() => outboxRepository.getAll()).thenAnswer((_) async => Right([item]));

    var attempt = 0;
    when(() => remoteDataSource.pushOutbox(any())).thenAnswer((_) async {
      attempt++;
      if (attempt == 1) {
        throw _transientNetworkFailure();
      }
    });

    // First sync attempt: backend/network is down, item is kept pending.
    await repository.pushOutbox();
    verifyNever(() => outboxRepository.remove('outbox-retry'));
    verify(() => outboxRepository.recordFailure('outbox-retry', any())).called(1);

    // Second sync attempt (e.g. once connectivity returns): the same
    // still-pending item is retried — and only removed, exactly once, now
    // that it has actually succeeded.
    await repository.pushOutbox();
    verify(() => outboxRepository.remove('outbox-retry')).called(1);
    expect(attempt, 2);
  });

  test('a permanently invalid item is preserved, not silently deleted, '
      'while unrelated items keep syncing on every attempt', () async {
    await putProduct('bad');
    await putProduct('good');
    final badItem = _outboxItem('outbox-bad', 'bad');
    final goodItem = _outboxItem('outbox-good', 'good');

    when(() => outboxRepository.getAll())
        .thenAnswer((_) async => Right([badItem, goodItem]));
    when(() => remoteDataSource.pushOutbox(any())).thenAnswer((invocation) async {
      final body = invocation.positionalArguments.first as Map<String, dynamic>;
      if (body['entity_id'] == 'bad') {
        throw _rejected(statusCode: 422);
      }
    });

    // Run two sync cycles in a row, as auto-sync would.
    await repository.pushOutbox();
    await repository.pushOutbox();

    verifyNever(() => outboxRepository.remove('outbox-bad'));
    verify(() => outboxRepository.recordFailure('outbox-bad', any())).called(2);
    verify(() => outboxRepository.remove('outbox-good')).called(2);
  });
}
