import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/outbox.dart';
import '../../../../core/domain/repositories/outbox_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final OutboxRepository outboxRepository;

  ProductRepositoryImpl({required this.outboxRepository});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final box = HiveDatabase.productBox;
      final products = box.values.where((p) => !p.isDeleted).map((m) => m.toEntity()).toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final box = HiveDatabase.productBox;
      final product = box.values.firstWhere(
        (element) => element.barcode == barcode && !element.isDeleted,
        orElse: () => throw Exception('Product not found'),
      );
      return Right(product.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      final model = ProductModel.fromEntity(updatedProduct);
      await box.put(model.id, model);
      
      await outboxRepository.add(Outbox(
        id: const Uuid().v4(),
        entityType: 'PRODUCT',
        entityId: model.id,
        operation: OutboxOperation.upsert,
        createdAt: DateTime.now(),
      ));
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      final model = ProductModel.fromEntity(updatedProduct);
      await box.put(model.id, model);

      await outboxRepository.add(Outbox(
        id: const Uuid().v4(),
        entityType: 'PRODUCT',
        entityId: model.id,
        operation: OutboxOperation.upsert,
        createdAt: DateTime.now(),
      ));

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final box = HiveDatabase.productBox;
      final model = box.get(id);
      if (model != null) {
        final deletedProduct = model.copyWith(isDeleted: true, updatedAt: DateTime.now());
        await box.put(id, ProductModel.fromEntity(deletedProduct));

        await outboxRepository.add(Outbox(
          id: const Uuid().v4(),
          entityType: 'PRODUCT',
          entityId: id,
          operation: OutboxOperation.delete,
          createdAt: DateTime.now(),
        ));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
