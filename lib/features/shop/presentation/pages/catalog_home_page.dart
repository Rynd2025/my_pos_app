import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../billing/presentation/widgets/cart_bottom_sheet.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';

class CatalogHomePage extends StatefulWidget {
  const CatalogHomePage({super.key});

  @override
  State<CatalogHomePage> createState() => _CatalogHomePageState();
}

class _CatalogHomePageState extends State<CatalogHomePage> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            String title = "Shop Catalog";
            if (state is ShopLoaded) {
              title = state.shop.name;
            }
            return Text(title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22));
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              context.read<SalesBloc>().add(LoadSalesEvent());
              context.push('/sales');
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 28),
            onPressed: () => context.push('/scanner', extra: true),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.loading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = state.products;
          final categories = products.map((p) => p.category).toSet().toList();

          final filteredProducts = _searchQuery.isEmpty
              ? []
              : products.where((p) {
                  final query = _searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(query) ||
                      p.category.toLowerCase().contains(query) ||
                      p.barcode.toLowerCase().contains(query);
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SearchBar(
                  controller: _searchController,
                  hintText: "Search by name, category or barcode...",
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16)),
                  leading: const Icon(Icons.search_rounded),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  elevation: const WidgetStatePropertyAll<double>(0),
                  backgroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  shape: WidgetStatePropertyAll<OutlinedBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), 
                      side: BorderSide(color: Colors.grey.shade200))),
                ),
              ),
              Expanded(
                child: _searchQuery.isNotEmpty
                    ? _buildSearchResults(filteredProducts)
                    : _buildCategories(categories),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<BillingBloc, BillingState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'manage_products',
                onPressed: () => context.push('/products'),
                child: const Icon(Icons.inventory_2_rounded),
              ),
              const SizedBox(height: 12),
              Badge(
                label: Text("${state.cartItems.length}"),
                isLabelVisible: state.cartItems.isNotEmpty,
                child: FloatingActionButton.extended(
                  heroTag: 'cart_btn',
                  onPressed: _showCart,
                  label: const Text("CART", style: TextStyle(fontWeight: FontWeight.bold)),
                  icon: const Icon(Icons.shopping_cart_rounded),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(List products) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No products found", style: TextStyle(color: Colors.grey, fontSize: 18)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: p.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(p.image), fit: BoxFit.cover),
                  )
                : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${p.category} • ${p.price.toStringAsFixed(3)} TND"),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor),
            onPressed: () {
              context.read<BillingBloc>().add(ScanBarcodeEvent(p.barcode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Added ${p.name} to cart"),
                  duration: const Duration(milliseconds: 500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          onTap: () => context.push('/products/edit/${p.id}', extra: p),
        );
      },
    );
  }

  Widget _buildCategories(List<String> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("No categories yet", style: TextStyle(color: Colors.grey, fontSize: 18)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.push('/products/add'),
              child: const Text("Add First Product"),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL CART",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2),
                  ),
                  Text(
                    "${state.totalAmount.toStringAsFixed(3)} TND",
                    style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                        letterSpacing: -1),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryCard(cat);
            },
          ),
          const SizedBox(height: 100), // Spacing for FAB
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/catalog/category/$category'),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              category,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
