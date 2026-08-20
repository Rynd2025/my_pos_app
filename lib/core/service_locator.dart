import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

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
import '../../features/product/data/repositories/product_import_repository_impl.dart';
import '../../features/product/domain/repositories/product_import_repository.dart';

import 'domain/repositories/outbox_repository.dart';
import 'data/repositories/outbox_repository_impl.dart';
import 'network/auth_interceptor.dart';
import 'services/sync_service.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/sync/domain/repositories/sync_repository.dart';
import '../../features/sync/data/repositories/sync_repository_impl.dart';
import '../../features/sync/data/datasources/sync_remote_data_source.dart';
import '../../features/sync/presentation/bloc/sync_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://108.181.196.138:8000'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    dio.interceptors.add(AuthInterceptor(secureStorage: sl()));
    return dio;
  });

  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => SyncService());

  sl.registerLazySingleton<OutboxRepository>(() => OutboxRepositoryImpl());

  // Features - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), secureStorage: sl()),
  );

  // Features - Sync
  sl.registerFactory(() => SyncBloc(syncRepository: sl()));
  sl.registerLazySingleton<SyncRemoteDataSource>(
    () => SyncRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(remoteDataSource: sl(), outboxRepository: sl()),
  );

  // Features - Product
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      productImportRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(outboxRepository: sl()),
  );
  sl.registerLazySingleton<ProductImportRepository>(
    () => ProductImportRepositoryImpl(client: sl()),
  );

  // Features - Shop
  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(outboxRepository: sl()),
  );

  // Features - Sales
  sl.registerFactory(
    () => SalesBloc(
      getSalesUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetSalesUseCase(sl()));
  sl.registerLazySingleton(() => SaveSaleUseCase(sl()));
  sl.registerLazySingleton(() => GetNextTicketNumberUseCase(sl()));
  sl.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(outboxRepository: sl()),
  );

  // Features - Customer
  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      createCustomerUseCase: sl(),
      recordPaymentUseCase: sl(),
      getLedgerUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => CreateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => RecordPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => GetLedgerUseCase(sl()));
  sl.registerLazySingleton(() => AddDebtUseCase(sl()));
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(outboxRepository: sl()),
  );

  // Features - Billing
  sl.registerFactory(
    () => BillingBloc(
      getProductByBarcodeUseCase: sl(),
      saveSaleUseCase: sl(),
      getNextTicketNumberUseCase: sl(),
      updateProductUseCase: sl(),
      addDebtUseCase: sl(),
    ),
  );

  // Features - Settings / Printer
  sl.registerFactory(
    () => PrinterBloc(
      repository: sl(),
    ),
  );
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(),
  );
}
