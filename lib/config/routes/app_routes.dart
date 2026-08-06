import 'package:go_router/go_router.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/shop/presentation/pages/catalog_home_page.dart';
import '../../features/shop/presentation/pages/category_products_page.dart';
import '../../features/sales/presentation/pages/sales_history_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CatalogHomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) {
            final isContinuous = state.extra as bool? ?? false;
            return ScannerPage(isContinuous: isContinuous);
          },
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: 'catalog/category/:name',
          builder: (context, state) {
            final category = state.pathParameters['name'] ?? '';
            return CategoryProductsPage(category: category);
          },
        ),
        GoRoute(
          path: 'sales',
          builder: (context, state) => const SalesHistoryPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/pos',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) {
            final barcode = state.extra as String?;
            return AddProductPage(initialBarcode: barcode);
          },
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
  ],
);
