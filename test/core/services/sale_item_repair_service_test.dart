// Regression coverage for the SaleItem.saleId repair migration: sales saved
// before the producer-side fix have every item's saleId stuck at '' (see
// billing_bloc_test.dart for the producer-side regression test). This must
// be deterministically repairable from data already on the device, without
// discarding anything, and must be safe to run repeatedly.
import 'dart:io';

import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/core/services/sale_item_repair_service.dart';
import 'package:billing_app/features/sales/data/models/sale_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sale_item_repair_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(SaleModelAdapter());
    Hive.registerAdapter(SaleItemModelAdapter());
    await Hive.openBox<SaleModel>(HiveDatabase.salesBoxName);
    await Hive.openBox<SaleItemModel>(HiveDatabase.saleItemBoxName);
    await Hive.openBox(HiveDatabase.settingsBoxName);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    await HiveDatabase.salesBox.clear();
    await HiveDatabase.saleItemBox.clear();
    await HiveDatabase.settingsBox.clear();
  });

  SaleItemModel item(String id, {required String saleId}) => SaleItemModel(
        id: id,
        saleId: saleId,
        productId: 'p1',
        productName: 'Test product',
        quantity: 1,
        priceAtSaleMillimes: 1000,
        purchasePriceAtSaleMillimes: 500,
        createdAt: DateTime(2026, 1, 1),
      );

  test('repairs an item whose saleId was never set (the historical bug), '
      'using the parent Sale\'s own id — deterministic, nothing discarded', () async {
    const saleId = '11111111-1111-1111-1111-111111111111';
    final brokenItem = item('item-1', saleId: '');

    await HiveDatabase.salesBox.put(
      saleId,
      SaleModel(
        id: saleId,
        ticketNumber: 'TKT-000001',
        createdAt: DateTime(2026, 1, 1),
        items: [brokenItem],
        totalMillimes: 1000,
        paidMillimes: 1000,
        dueMillimes: 0,
        paymentMethodIndex: 0,
      ),
    );
    await HiveDatabase.saleItemBox.put('item-1', brokenItem);

    await SaleItemRepairService.repairIfNeeded();

    final repaired = HiveDatabase.saleItemBox.get('item-1');
    expect(repaired, isNotNull);
    expect(repaired!.saleId, saleId);
  });

  test('leaves already-valid saleId items untouched', () async {
    const saleId = '22222222-2222-2222-2222-222222222222';
    final goodItem = item('item-2', saleId: saleId);

    await HiveDatabase.salesBox.put(
      saleId,
      SaleModel(
        id: saleId,
        ticketNumber: 'TKT-000002',
        createdAt: DateTime(2026, 1, 1),
        items: [goodItem],
        totalMillimes: 1000,
        paidMillimes: 1000,
        dueMillimes: 0,
        paymentMethodIndex: 0,
      ),
    );
    await HiveDatabase.saleItemBox.put('item-2', goodItem);

    await SaleItemRepairService.repairIfNeeded();

    expect(HiveDatabase.saleItemBox.get('item-2')!.saleId, saleId);
  });

  test('is idempotent — running it again after a repair changes nothing '
      'and does not re-scan every sale on every app launch', () async {
    const saleId = '33333333-3333-3333-3333-333333333333';
    final brokenItem = item('item-3', saleId: '');

    await HiveDatabase.salesBox.put(
      saleId,
      SaleModel(
        id: saleId,
        ticketNumber: 'TKT-000003',
        createdAt: DateTime(2026, 1, 1),
        items: [brokenItem],
        totalMillimes: 1000,
        paidMillimes: 1000,
        dueMillimes: 0,
        paymentMethodIndex: 0,
      ),
    );
    await HiveDatabase.saleItemBox.put('item-3', brokenItem);

    await SaleItemRepairService.repairIfNeeded();
    expect(HiveDatabase.saleItemBox.get('item-3')!.saleId, saleId);

    // Simulate a completely fresh sale added after the repair flag was
    // already set, with its saleId correctly populated by the (now fixed)
    // producer — a second run must not touch it, and must not crash.
    const secondSaleId = '44444444-4444-4444-4444-444444444444';
    final freshItem = item('item-4', saleId: secondSaleId);
    await HiveDatabase.salesBox.put(
      secondSaleId,
      SaleModel(
        id: secondSaleId,
        ticketNumber: 'TKT-000004',
        createdAt: DateTime(2026, 1, 1),
        items: [freshItem],
        totalMillimes: 1000,
        paidMillimes: 1000,
        dueMillimes: 0,
        paymentMethodIndex: 0,
      ),
    );
    await HiveDatabase.saleItemBox.put('item-4', freshItem);

    await SaleItemRepairService.repairIfNeeded();

    expect(HiveDatabase.saleItemBox.get('item-3')!.saleId, saleId);
    expect(HiveDatabase.saleItemBox.get('item-4')!.saleId, secondSaleId);
  });
}
