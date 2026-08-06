import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';

class CategoryProductsPage extends StatelessWidget {
  final String category;
  const CategoryProductsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final products = state.products
              .where((p) => p.category == category)
              .toList();

          if (products.isEmpty) {
            return const Center(child: Text("No products in this category"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
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
                subtitle: Text("${p.price.toStringAsFixed(3)} TND"),
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
        },
      ),
    );
  }
}
