import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sales_bloc.dart';
import '../../domain/entities/sale.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesError) {
            return Center(child: Text(state.message));
          } else if (state is SalesLoaded) {
            if (state.sales.isEmpty) {
              return const Center(child: Text('No sales found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.sales.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sale = state.sales[index];
                return _buildSaleCard(context, sale);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Sale sale) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          'Total: ${sale.totalAmount.toStringAsFixed(3)} TND',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(dateFormat.format(sale.dateTime),
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const Divider(),
                ...sale.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity} x ${item.productName}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '${(item.price * item.quantity).toStringAsFixed(3)} TND',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
              ],
            ),
          )
        ],
      ),
    );
  }
}
