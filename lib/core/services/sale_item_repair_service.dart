import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../features/sales/data/models/sale_model.dart';
import '../data/hive_database.dart';

/// One-time local data repair for a historical bug: SaleItem.saleId was
/// always written as an empty string instead of the parent Sale's id (see
/// billing_bloc.dart / sale_repository_impl.dart), which the backend
/// correctly rejects with "badly formed hexadecimal UUID string" on every
/// sync attempt — permanently stuck in the outbox on any device that made
/// a sale before the producer-side fix.
///
/// Each Sale's own `id` was always valid, and a Sale always names its own
/// items' ids in `items`, so this can be repaired deterministically from
/// data already on the device — no guessing, nothing discarded.
class SaleItemRepairService {
  static const _repairedFlagKey = 'sale_item_saleid_repaired_v1';

  static Future<void> repairIfNeeded() async {
    final settingsBox = HiveDatabase.settingsBox;
    if (settingsBox.get(_repairedFlagKey, defaultValue: false) == true) return;

    try {
      final saleBox = HiveDatabase.salesBox;
      final itemBox = HiveDatabase.saleItemBox;
      var repaired = 0;

      for (final sale in saleBox.values) {
        for (final embeddedItem in sale.items) {
          final stored = itemBox.get(embeddedItem.id);
          if (stored == null) continue;
          if (Uuid.isValidUUID(fromString: stored.saleId)) continue;

          await itemBox.put(
            stored.id,
            SaleItemModel(
              id: stored.id,
              saleId: sale.id,
              productId: stored.productId,
              productName: stored.productName,
              quantity: stored.quantity,
              priceAtSaleMillimes: stored.priceAtSaleMillimes,
              purchasePriceAtSaleMillimes: stored.purchasePriceAtSaleMillimes,
              createdAt: stored.createdAt,
              updatedAt: stored.updatedAt,
              isDeleted: stored.isDeleted,
            ),
          );
          repaired++;
        }
      }

      if (repaired > 0) {
        debugPrint('SaleItemRepairService: repaired $repaired sale item(s) with a missing saleId');
      }
      await settingsBox.put(_repairedFlagKey, true);
    } catch (e) {
      debugPrint('SaleItemRepairService: repair failed, will retry next launch: $e');
    }
  }
}
