import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';

abstract class SyncRepository {
  Future<Either<Failure, void>> pushOutbox();
  Future<Either<Failure, void>> pullUpdates();
  Future<Either<Failure, void>> restoreShop();
}
