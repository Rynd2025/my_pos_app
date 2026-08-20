import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/sales/data/models/sale_model.dart';
import '../../features/customer/data/models/customer_model.dart';
import '../../features/customer/data/models/payment_model.dart';
import '../../features/customer/data/models/ledger_entry_model.dart';
import 'models/outbox_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String salesBoxName = 'sales';
  static const String saleItemBoxName = 'sale_items';
  static const String customerBoxName = 'customers';
  static const String paymentBoxName = 'payments';
  static const String ledgerBoxName = 'ledger';
  static const String outboxBoxName = 'outbox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());
    Hive.registerAdapter(SaleModelAdapter());
    Hive.registerAdapter(SaleItemModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(PaymentModelAdapter());
    Hive.registerAdapter(LedgerEntryModelAdapter());
    Hive.registerAdapter(OutboxModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox<SaleModel>(salesBoxName);
    await Hive.openBox<SaleItemModel>(saleItemBoxName);
    await Hive.openBox<CustomerModel>(customerBoxName);
    await Hive.openBox<PaymentModel>(paymentBoxName);
    await Hive.openBox<LedgerEntryModel>(ledgerBoxName);
    await Hive.openBox<OutboxModel>(outboxBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box<SaleModel> get salesBox => Hive.box<SaleModel>(salesBoxName);
  static Box<SaleItemModel> get saleItemBox => Hive.box<SaleItemModel>(saleItemBoxName);
  static Box<CustomerModel> get customerBox =>
      Hive.box<CustomerModel>(customerBoxName);
  static Box<PaymentModel> get paymentBox =>
      Hive.box<PaymentModel>(paymentBoxName);
  static Box<LedgerEntryModel> get ledgerBox =>
      Hive.box<LedgerEntryModel>(ledgerBoxName);
  static Box<OutboxModel> get outboxBox =>
      Hive.box<OutboxModel>(outboxBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
}
