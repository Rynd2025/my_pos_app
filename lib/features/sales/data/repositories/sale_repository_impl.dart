import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final box = HiveDatabase.salesBox;
      final sales = box.values.map((m) => m.toEntity()).toList();
      // Sort by date desc
      sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getNextTicketNumber() async {
    try {
      final box = HiveDatabase.salesBox;
      final count = box.length;
      final nextNumber = count + 1;
      final formatted = nextNumber.toString().padLeft(6, '0');
      return Right('TKT-$formatted');
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSale(Sale sale) async {
    try {
      final box = HiveDatabase.salesBox;
      await box.put(sale.id, SaleModel.fromEntity(sale));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
