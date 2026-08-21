import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/domain/repositories/outbox_repository.dart';
import '../datasources/sync_remote_data_source.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../../../core/domain/entities/outbox.dart';

import '../../../product/data/models/product_model.dart';
import '../../../shop/data/models/shop_model.dart';
import '../../../customer/data/models/customer_model.dart';
import '../../../sales/data/models/sale_model.dart';
import '../../../customer/data/models/payment_model.dart';
import '../../../customer/data/models/ledger_entry_model.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncRemoteDataSource remoteDataSource;
  final OutboxRepository outboxRepository;

  SyncRepositoryImpl({
    required this.remoteDataSource,
    required this.outboxRepository,
  });

  @override
  Future<Either<Failure, void>> pushOutbox() async {
    try {
      final outboxResult = await outboxRepository.getAll();
      return outboxResult.fold(
        (failure) => Left(failure),
        (outboxItems) async {
          if (outboxItems.isEmpty) return const Right(null);

          // Each item is pushed and resolved independently: one rejected or
          // failed item must never block the items queued behind it. An
          // item is only ever removed once the backend has actually
          // confirmed success — a failure (permanent validation error or a
          // transient network/server error alike) leaves it in place, with
          // the failure recorded on it, and processing moves on.
          for (final item in outboxItems) {
            final data = _getEntityJson(item.entityType, item.entityId);
            if (data == null) {
              // Nothing left locally to push for this entity (e.g. it was
              // already removed) — stale reference, safe to drop.
              await outboxRepository.remove(item.id);
              continue;
            }

            try {
              await remoteDataSource.pushOutbox({
                'id': item.id,
                'entity_type': item.entityType,
                'entity_id': item.entityId,
                'operation': item.operation.name,
                'data': data,
                'created_at': item.createdAt.toIso8601String(),
              });
              await outboxRepository.remove(item.id);
            } catch (e) {
              final description = _describeError(e);
              debugPrint(
                  'Sync push failed for ${item.entityType} (kept for retry): $description');
              await outboxRepository.recordFailure(item.id, description);
            }
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pullUpdates() async {
    try {
      final lastCursor = HiveDatabase.settingsBox.get('sync_cursor', defaultValue: 0);
      final updates = await remoteDataSource.pullUpdates(lastCursor);
      
      final List items = updates['items'] ?? [];
      for (var update in items) {
        await _applyUpdate(update);
      }
      
      await HiveDatabase.settingsBox.put('sync_cursor', updates['new_cursor']);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreShop() async {
    try {
      final data = await remoteDataSource.restoreShop();
      
      // Clear all business boxes
      await HiveDatabase.productBox.clear();
      await HiveDatabase.shopBox.clear();
      await HiveDatabase.customerBox.clear();
      await HiveDatabase.salesBox.clear();
      await HiveDatabase.saleItemBox.clear();
      await HiveDatabase.paymentBox.clear();
      await HiveDatabase.ledgerBox.clear();
      await HiveDatabase.outboxBox.clear();

      final List products = data['products'] ?? [];
      for (var p in products) {
        final model = ProductModel.fromJson(p);
        await HiveDatabase.productBox.put(model.id, model);
      }

      final Map<String, dynamic>? shop = data['shop'];
      if (shop != null) {
        final model = ShopModel.fromJson(shop);
        await HiveDatabase.shopBox.put(model.id, model);
      }

      final List customers = data['customers'] ?? [];
      for (var c in customers) {
        final model = CustomerModel.fromJson(c);
        await HiveDatabase.customerBox.put(model.id, model);
      }

      final List sales = data['sales'] ?? [];
      for (var s in sales) {
        final model = SaleModel.fromJson(s);
        await HiveDatabase.salesBox.put(model.id, model);
      }

      final List saleItems = data['sale_items'] ?? [];
      for (var si in saleItems) {
        final model = SaleItemModel.fromJson(si);
        await HiveDatabase.saleItemBox.put(model.id, model);
      }

      final List payments = data['payments'] ?? [];
      for (var pay in payments) {
        final model = PaymentModel.fromJson(pay);
        await HiveDatabase.paymentBox.put(model.id, model);
      }

      final List ledger = data['ledger_entries'] ?? [];
      for (var le in ledger) {
        final model = LedgerEntryModel.fromJson(le);
        await HiveDatabase.ledgerBox.put(model.id, model);
      }

      await HiveDatabase.settingsBox.put('sync_cursor', data['cursor']);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Summarizes a failed push for logging/storage — status code or error
  /// type only. Never includes the request/response body, which could
  /// contain customer names, phone numbers, or amounts.
  String _describeError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      return status != null ? 'HTTP $status' : 'network error (${e.type.name})';
    }
    return e.runtimeType.toString();
  }

  Map<String, dynamic>? _getEntityJson(String type, String id) {
    switch (type) {
      case 'PRODUCT':
        return HiveDatabase.productBox.get(id)?.toJson();
      case 'SHOP':
        return HiveDatabase.shopBox.values.where((s) => s.id == id).firstOrNull?.toJson();
      case 'CUSTOMER':
        return HiveDatabase.customerBox.get(id)?.toJson();
      case 'SALE':
        return HiveDatabase.salesBox.get(id)?.toJson();
      case 'SALE_ITEM':
        return HiveDatabase.saleItemBox.get(id)?.toJson();
      case 'PAYMENT':
        return HiveDatabase.paymentBox.get(id)?.toJson();
      case 'LEDGER_ENTRY':
        return HiveDatabase.ledgerBox.get(id)?.toJson();
    }
    return null;
  }

  Future<void> _applyUpdate(Map<String, dynamic> update) async {
    final type = update['type'];
    final data = update['data'];
    final bool isDeleted = update['is_deleted'] ?? false;

    switch (type) {
      case 'PRODUCT':
        final model = ProductModel.fromJson(data);
        if (isDeleted) {
          await HiveDatabase.productBox.delete(model.id);
        } else {
          await HiveDatabase.productBox.put(model.id, model);
        }
        break;
      case 'SHOP':
        final model = ShopModel.fromJson(data);
        await HiveDatabase.shopBox.put(model.id, model);
        break;
      case 'CUSTOMER':
        final model = CustomerModel.fromJson(data);
        if (isDeleted) {
          await HiveDatabase.customerBox.delete(model.id);
        } else {
          await HiveDatabase.customerBox.put(model.id, model);
        }
        break;
      case 'SALE':
        final model = SaleModel.fromJson(data);
        if (isDeleted) {
          await HiveDatabase.salesBox.delete(model.id);
        } else {
          await HiveDatabase.salesBox.put(model.id, model);
        }
        break;
      case 'SALE_ITEM':
        final model = SaleItemModel.fromJson(data);
        if (isDeleted) {
          await HiveDatabase.saleItemBox.delete(model.id);
        } else {
          await HiveDatabase.saleItemBox.put(model.id, model);
        }
        break;
      case 'PAYMENT':
        final model = PaymentModel.fromJson(data);
        if (isDeleted) {
          await HiveDatabase.paymentBox.delete(model.id);
        } else {
          await HiveDatabase.paymentBox.put(model.id, model);
        }
        break;
      case 'LEDGER_ENTRY':
        final model = LedgerEntryModel.fromJson(data);
        if (isDeleted) {
          await HiveDatabase.ledgerBox.delete(model.id);
        } else {
          await HiveDatabase.ledgerBox.put(model.id, model);
        }
        break;
    }
  }
}
