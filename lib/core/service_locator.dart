import 'package:get_it/get_it.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_usecases.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';
import '../../features/settings/data/repositories/printer_repository_impl.dart';
import '../../features/settings/domain/repositories/printer_repository.dart';
import '../../features/settings/presentation/bloc/printer_bloc.dart';
import '../../features/sales/data/repositories/sale_repository_impl.dart';
import '../../features/sales/domain/repositories/sale_repository.dart';
import '../../features/sales/domain/usecases/sale_usecases.dart';
import '../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/domain/usecases/customer_usecases.dart';
import '../../features/customer/presentation/bloc/customer_bloc.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';

import 'package:http/http.dart' as http;
import '../../features/product/data/repositories/product_import_repository_impl.dart';
import '../../features/product/domain/repositories/product_import_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client());

  // Features - Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      productImportRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PrinterBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => SalesBloc(
      getSalesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      createCustomerUseCase: sl(),
      recordPaymentUseCase: sl(),
      getLedgerUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => BillingBloc(
      getProductByBarcodeUseCase: sl(),
      saveSaleUseCase: sl(),
      getNextTicketNumberUseCase: sl(),
      updateProductUseCase: sl(),
      addDebtUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));

  sl.registerLazySingleton(() => GetSalesUseCase(sl()));
  sl.registerLazySingleton(() => SaveSaleUseCase(sl()));
  sl.registerLazySingleton(() => GetNextTicketNumberUseCase(sl()));

  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => CreateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => RecordPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => GetLedgerUseCase(sl()));
  sl.registerLazySingleton(() => AddDebtUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );

  sl.registerLazySingleton<ProductImportRepository>(
    () => ProductImportRepositoryImpl(client: sl()),
  );

  sl.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(),
  );

  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(),
  );

  // Features - Shop
  // Use cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(),
  );

  // Features - Settings / Printer
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(),
  );
}
