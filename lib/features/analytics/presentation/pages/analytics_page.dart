import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';
import '../../../sales/presentation/bloc/sales_event.dart';
import '../../../sales/presentation/bloc/sales_state.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../customer/presentation/bloc/customer_event.dart';
import '../../../customer/presentation/bloc/customer_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../sales/domain/entities/sale.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<SalesBloc>().add(LoadSales());
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<ProductBloc>().add(LoadProducts());
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'SÉLECTIONNEZ UNE PÉRIODE',
      saveText: 'VALIDER',
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyses & Statistiques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateFilterHeader(),
            const SizedBox(height: 24),
            _buildSectionHeader('Ventes & Profit'),
            const SizedBox(height: 12),
            _buildSalesOverview(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Inventaire'),
            const SizedBox(height: 12),
            _buildInventoryOverview(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Dettes Clients'),
            const SizedBox(height: 12),
            _buildDebtOverview(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Produits les plus vendus'),
            const SizedBox(height: 12),
            _buildTopProducts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterHeader() {
    final dateRangeText = _selectedDateRange == null
        ? 'Toutes les ventes'
        : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PÉRIODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(dateRangeText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _clearFilter,
            ),
          ElevatedButton(
            onPressed: _selectDateRange,
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Filtrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  List<Sale> _getFilteredSales(List<Sale> allSales) {
    if (_selectedDateRange == null) return allSales;
    
    // Normalize range to include full days
    final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day, 0, 0, 0);
    final endDateExclusive = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59, 999);

    return allSales.where((sale) {
      return sale.createdAt.isAfter(startDate) && sale.createdAt.isBefore(endDateExclusive);
    }).toList();
  }

  Widget _buildSalesOverview(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        final filteredSales = _getFilteredSales(state.sales);
        final totalSalesCount = filteredSales.length;
        final int totalAmountMillimes = filteredSales.fold<int>(0, (sum, s) => sum + s.totalMillimes);
        
        int totalProfitMillimes = 0;
        for (var sale in filteredSales) {
          for (var item in sale.items) {
            totalProfitMillimes += item.profitMillimes;
          }
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('Total Ventes', totalSalesCount.toString(), Icons.shopping_cart, Colors.blue),
            _buildStatCard('Chiffre d\'Affaires', CurrencyUtils.formatMillimes(totalAmountMillimes), Icons.monetization_on, Colors.green),
            _buildStatCard('Profit Estimé', CurrencyUtils.formatMillimes(totalProfitMillimes), Icons.trending_up, Colors.orange),
            _buildStatCard('Marge Moyenne', totalAmountMillimes > 0 ? '${((totalProfitMillimes / totalAmountMillimes) * 100).toStringAsFixed(1)}%' : '0%', Icons.pie_chart, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildInventoryOverview(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final totalProducts = state.products.length;
        final lowStockProducts = state.products.where((p) => p.stock <= (p.lowStockThreshold ?? 5)).toList();
        final outOfStock = state.products.where((p) => p.stock <= 0).length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Produits Totaux', totalProducts.toString(), Icons.inventory_2, Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Rupture de Stock', outOfStock.toString(), Icons.warning_amber, Colors.red)),
              ],
            ),
            if (lowStockProducts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alertes Stock Faible', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 8),
                    ...lowStockProducts.take(3).map((p) => Text('• ${p.name}: ${p.stock} restant(s)', style: const TextStyle(fontSize: 12))),
                    if (lowStockProducts.length > 3)
                       Text('... et ${lowStockProducts.length - 3} others', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDebtOverview(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        final customersWithDebt = state.customers.where((c) => c.balanceMillimes > 0).toList();
        final int totalDebtMillimes = customersWithDebt.fold<int>(0, (sum, c) => sum + c.balanceMillimes);

        return _buildStatCard(
          'Total à Récupérer',
          CurrencyUtils.formatMillimes(totalDebtMillimes),
          Icons.people_outline,
          Colors.redAccent,
          subtitle: '${customersWithDebt.length} clients endettés',
        );
      },
    );
  }

  Widget _buildTopProducts(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        final filteredSales = _getFilteredSales(state.sales);
        final Map<String, int> productSales = {};
        final Map<String, String> productNames = {};

        for (final sale in filteredSales) {
          for (final item in sale.items) {
            final String? id = item.productId;
            if (id != null) {
              productSales[id] = (productSales[id] ?? 0) + item.quantity;
              productNames[id] = item.productName;
            }
          }
        }

        final sortedIds = productSales.keys.toList()..sort((a, b) => (productSales[b] ?? 0).compareTo(productSales[a] ?? 0));

        if (sortedIds.isEmpty) {
          return const Center(child: Text('Aucune donnée de vente pour cette période', style: TextStyle(fontSize: 12, color: Colors.grey)));
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedIds.length > 5 ? 5 : sortedIds.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final id = sortedIds[index];
              return ListTile(
                title: Text(productNames[id] ?? 'Inconnu', style: const TextStyle(fontSize: 14)),
                trailing: Text('${productSales[id] ?? 0} vendus', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
