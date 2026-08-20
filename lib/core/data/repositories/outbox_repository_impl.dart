import 'package:fpdart/fpdart.dart';
import '../../error/failure.dart';
import '../../domain/entities/outbox.dart';
import '../../domain/repositories/outbox_repository.dart';
import '../../service_locator.dart';
import '../../services/sync_service.dart';
import '../hive_database.dart';
import '../models/outbox_model.dart';

class OutboxRepositoryImpl implements OutboxRepository {
  @override
  Future<Either<Failure, void>> add(Outbox outbox) async {
    try {
      await HiveDatabase.outboxBox.put(outbox.id, OutboxModel.fromEntity(outbox));
      // Every entity repository funnels its writes through here, so this is
      // the single choke point for "sync whenever the local db changes."
      sl<SyncService>().notifyLocalChange();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Outbox>>> getAll() async {
    try {
      final outbox = HiveDatabase.outboxBox.values.map((m) => m.toEntity()).toList();
      outbox.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(outbox);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String id) async {
    try {
      await HiveDatabase.outboxBox.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clear() async {
    try {
      await HiveDatabase.outboxBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
