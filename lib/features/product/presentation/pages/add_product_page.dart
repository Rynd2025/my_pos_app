import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/currency_utils.dart';

class AddProductPage extends StatefulWidget {
  final String? initialBarcode;
  const AddProductPage({super.key, this.initialBarcode});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name = '';
  late String? _barcode;
  late double _price = 0.0;
  late double _purchasePrice = 0.0;
  late int _stock = 0;
  late int _lowStockThreshold = 5;
  late String? _brand = '';
  late String? _category = '';
  late String? _unit = '';

  @override
  void initState() {
    super.initState();
    _barcode = widget.initialBarcode;
  }

  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcode = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productState = context.read<ProductBloc>().state;
      if (_barcode != null && _barcode!.isNotEmpty) {
        final existingProduct =
            productState.products.where((p) => p.barcode == _barcode).firstOrNull;

        if (existingProduct != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Un produit avec le code "$_barcode" existe déjà !'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final product = Product(
        id: Uuid().v4(),
        name: _name,
        barcode: _barcode?.isEmpty == true ? null : _barcode,
        price: _price,
        purchasePrice: _purchasePrice,
        stock: _stock,
        lowStockThreshold: _lowStockThreshold,
        brand: _brand?.isEmpty == true ? null : _brand,
        category: _category?.isEmpty == true ? null : _category,
        unit: _unit?.isEmpty == true ? null : _unit,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left,
                size: 28, color: AppTheme.primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Ajouter un Produit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Code-barres (Optionnel)'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          decoration: const InputDecoration(
                            hintText: 'Scanner ou saisir...',
                          ),
                          onSaved: (value) => _barcode = value,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor),
                          onPressed: _scanBarcode,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Nom du Produit'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'ex: 4 œufs, Cigarette...',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Le nom est requis'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Prix (TND)'),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prix d\'achat', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            TextFormField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '0.000', suffixText: ' DT'),
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
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '0.000', suffixText: ' DT'),
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
                            const InputLabel(text: 'Stock Initial'),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              initialValue: '0',
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
                              keyboardType: TextInputType.number,
                              initialValue: '5',
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
                              onSaved: (value) => _category = value,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Unité (ex: pack, kg, piece)'),
                  TextFormField(
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
            icon: Icons.add_circle,
            label: 'Ajouter le Produit',
          ),
        ));
  }
}
