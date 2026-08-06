import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  @override
  Future<Either<Failure, void>> saveSale(Sale sale) async {
    try {
      final box = HiveDatabase.salesBox;
      final model = SaleModel.fromEntity(sale);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final box = HiveDatabase.salesBox;
      final sales = box.values.map((m) => m.toEntity()).toList();
      // Sort by date descending (newest first)
      sales.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
