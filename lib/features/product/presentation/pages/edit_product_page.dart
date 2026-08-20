import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/currency_utils.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;
  late double _purchasePrice;
  late int _stock;
  late int _lowStockThreshold;
  late String? _brand;
  late String? _category;
  late String? _unit;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _purchasePrice = widget.product.purchasePrice;
    _stock = widget.product.stock;
    _lowStockThreshold = widget.product.lowStockThreshold ?? 5;
    _brand = widget.product.brand;
    _category = widget.product.category;
    _unit = widget.product.unit;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = widget.product.copyWith(
        name: _name,
        price: _price,
        purchasePrice: _purchasePrice,
        stock: _stock,
        lowStockThreshold: _lowStockThreshold,
        brand: _brand,
        category: _category,
        unit: _unit,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left,
                size: 32, color: AppTheme.primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Modifier le Produit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.product.barcode != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CODE-BARRES',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.7))),
                              const SizedBox(height: 2),
                              Text(widget.product.barcode!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace')),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const InputLabel(text: 'Prix (TND)'),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prix d\'achat', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            TextFormField(
                              initialValue: _purchasePrice.toStringAsFixed(3),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(suffixText: ' DT'),
                              onSaved: (value) => _purchasePrice = double.tryParse(value ?? '') ?? 0.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prix de vente', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            TextFormField(
                              initialValue: _price.toStringAsFixed(3),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(suffixText: ' DT'),
                              validator: AppValidators.price,
                              onSaved: (value) => _price = double.parse(value!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Stock'),
                            TextFormField(
                              initialValue: _stock.toString(),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _stock = int.tryParse(value ?? '') ?? 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Alerte Stock Bas'),
                            TextFormField(
                              initialValue: _lowStockThreshold.toString(),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _lowStockThreshold = int.tryParse(value ?? '') ?? 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Marque'),
                            TextFormField(
                              initialValue: _brand,
                              onSaved: (value) => _brand = value,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel(text: 'Catégorie'),
                            TextFormField(
                              initialValue: _category,
                              onSaved: (value) => _category = value,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Unité'),
                  TextFormField(
                    initialValue: _unit,
                    onSaved: (value) => _unit = value,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: PrimaryButton(
            onPressed: _submit,
            icon: Icons.save,
            label: 'Enregistrer les modifications',
          ),
        ));
  }
}
