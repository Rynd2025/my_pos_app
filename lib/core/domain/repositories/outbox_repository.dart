import 'package:fpdart/fpdart.dart';
import '../../error/failure.dart';
import '../entities/outbox.dart';

abstract class OutboxRepository {
  Future<Either<Failure, void>> add(Outbox outbox);
  Future<Either<Failure, List<Outbox>>> getAll();
  Future<Either<Failure, void>> remove(String id);
  Future<Either<Failure, void>> clear();

  /// Records that a push attempt for [id] failed, without removing it —
  /// increments its retry count and stores a short, non-sensitive error
  /// description for later inspection. A no-op if the item is no longer
  /// in the outbox (e.g. it succeeded on a later attempt already).
  Future<Either<Failure, void>> recordFailure(String id, String error);
}
