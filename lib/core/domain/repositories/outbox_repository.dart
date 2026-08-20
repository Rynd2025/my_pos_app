import 'package:fpdart/fpdart.dart';
import '../../error/failure.dart';
import '../entities/outbox.dart';

abstract class OutboxRepository {
  Future<Either<Failure, void>> add(Outbox outbox);
  Future<Either<Failure, List<Outbox>>> getAll();
  Future<Either<Failure, void>> remove(String id);
  Future<Either<Failure, void>> clear();
}
