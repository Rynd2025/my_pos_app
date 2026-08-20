import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/outbox.dart';
import '../../../../core/domain/repositories/outbox_repository.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final OutboxRepository outboxRepository;

  SaleRepositoryImpl({required this.outboxRepository});

  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final box = HiveDatabase.salesBox;
      final sales = box.values.where((s) => !s.isDeleted).map((m) => m.toEntity()).toList();
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
      final saleBox = HiveDatabase.salesBox;
      final itemBox = HiveDatabase.saleItemBox;
      
      final updatedSale = sale.copyWith(updatedAt: DateTime.now());
      await saleBox.put(updatedSale.id, SaleModel.fromEntity(updatedSale));

      for (var item in updatedSale.items) {
        await itemBox.put(item.id, SaleItemModel.fromEntity(item));
        await outboxRepository.add(Outbox(
          id: const Uuid().v4(),
          entityType: 'SALE_ITEM',
          entityId: item.id,
          operation: OutboxOperation.upsert,
          createdAt: DateTime.now(),
        ));
      }

      await outboxRepository.add(Outbox(
        id: const Uuid().v4(),
        entityType: 'SALE',
        entityId: updatedSale.id,
        operation: OutboxOperation.upsert,
        createdAt: DateTime.now(),
      ));

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
