import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/outbox.dart';
import '../../../../core/domain/repositories/outbox_repository.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  final OutboxRepository outboxRepository;

  ShopRepositoryImpl({required this.outboxRepository});

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final box = HiveDatabase.shopBox;
      if (box.isEmpty) {
        return const Right(Shop());
      }
      return Right(box.values.first.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      final box = HiveDatabase.shopBox;
      final updatedShop = shop.copyWith(updatedAt: DateTime.now());
      final model = ShopModel.fromEntity(updatedShop);
      
      // Assume one shop for now, use fixed key or shop ID
      final key = model.id.isEmpty ? 'current_shop' : model.id;
      await box.put(key, model);

      await outboxRepository.add(Outbox(
        id: const Uuid().v4(),
        entityType: 'SHOP',
        entityId: model.id,
        operation: OutboxOperation.upsert,
        createdAt: DateTime.now(),
      ));

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
