import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';

class InventoryFillingPage extends StatefulWidget {
  const InventoryFillingPage({super.key});

  @override
  State<InventoryFillingPage> createState() => _InventoryFillingPageState();
}

class _InventoryFillingPageState extends State<InventoryFillingPage> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  Product? _selectedProduct;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  void _startScan() async {
    final barcode = await context.push<String>('/scanner');
    if (barcode != null && mounted) {
      _processBarcode(barcode);
    }
  }

  void _processBarcode(String barcode) {
    final state = context.read<ProductBloc>().state;
    final product = state.products.where((p) => p.barcode == barcode).firstOrNull;

    if (product != null) {
      _selectProduct(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit non trouvé ($barcode)'),
          action: SnackBarAction(
            label: 'Créer',
            onPressed: () => context.push('/products/add', extra: barcode),
          ),
        ),
      );
    }
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _qtyController.clear();
      _buyPriceController.text = product.purchasePrice.toStringAsFixed(3);
      _sellPriceController.text = product.price.toStringAsFixed(3);
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _save() async {
    if (_selectedProduct == null) return;
    
    final addQty = int.tryParse(_qtyController.text) ?? 0;
    final buyPrice = double.tryParse(_buyPriceController.text) ?? _selectedProduct!.purchasePrice;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? _selectedProduct!.price;

    setState(() => _isSaving = true);

    final updatedProduct = _selectedProduct!.copyWith(
      stock: _selectedProduct!.stock + addQty,
      purchasePrice: buyPrice,
      price: sellPrice,
    );

    context.read<ProductBloc>().add(UpdateProduct(updatedProduct));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedProduct!.name} mis à jour (+ $addQty)'), backgroundColor: Colors.green),
    );

    // Reset and stay on page for next item
    setState(() {
      _selectedProduct = null;
      _isSaving = false;
    });
    
    // Refresh products to ensure next search has latest stock
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remplir l\'inventaire'),
        actions: [
          if (_selectedProduct == null)
            IconButton(
              onPressed: _startScan,
              icon: const Icon(Icons.qr_code_scanner),
            ),
        ],
      ),
      body: _selectedProduct == null
          ? _buildSearchState()
          : _buildFillingForm(),
      bottomNavigationBar: _selectedProduct != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selectedProduct = null),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('ANNULER'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('ENREGISTRER', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou code-barres...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                      : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
                  onPressed: _startScan,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final filteredProducts = state.products.where((p) {
                final name = p.name.toLowerCase();
                final barcode = (p.barcode ?? '').toLowerCase();
                final brand = (p.brand ?? '').toLowerCase();
                return name.contains(_searchQuery) || barcode.contains(_searchQuery) || brand.contains(_searchQuery);
              }).toList();

              if (filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(child: Text('Aucun produit trouvé'));
              }

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('Recherchez ou scannez un produit', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProducts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${product.brand ?? ''}${product.brand != null && product.barcode != null ? ' • ' : ''}${product.barcode ?? ''}\nStock actuel: ${product.stock}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                    onTap: () => _selectProduct(product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFillingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedProduct!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Stock actuel: ${_selectedProduct!.stock}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                      if (_selectedProduct!.barcode != null)
                        Text('Code: ${_selectedProduct!.barcode}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('QUANTITÉ REÇUE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'unités',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRIX D\'ACHAT UNITAIRE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    TextField(
                      controller: _buyPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(suffixText: 'DT'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRIX DE VENTE UNITAIRE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    TextField(
                      controller: _sellPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(suffixText: 'DT'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
