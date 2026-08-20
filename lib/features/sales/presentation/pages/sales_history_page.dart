import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sales_bloc.dart';
import '../bloc/sales_event.dart';
import '../bloc/sales_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/sale.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<SalesBloc>().add(LoadSales());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Ventes'),
        centerTitle: true,
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state.status == SalesStatus.loading && state.sales.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sales.isEmpty) {
            return const Center(child: Text('Aucune vente enregistrée'));
          }

          return ListView.builder(
            itemCount: state.sales.length,
            itemBuilder: (context, index) {
              final sale = state.sales[index];
              return _buildExpandableSaleCard(sale);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpandableSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: sale.paymentMethod == PaymentMethod.cash 
            ? Colors.green.withValues(alpha: 0.1) 
            : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            sale.paymentMethod == PaymentMethod.cash ? Icons.payments_outlined : Icons.credit_card,
            color: sale.paymentMethod == PaymentMethod.cash ? Colors.green : Colors.orange,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(sale.ticketNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(CurrencyUtils.formatMillimes(sale.totalMillimes), 
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        subtitle: Text(
          '${DateFormat('dd/MM HH:mm').format(sale.createdAt)} • ${sale.paymentMethod == PaymentMethod.cash ? 'ESPÈCES' : 'CRÉDIT'}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Expanded(child: Text(item.productName)),
                      Text(CurrencyUtils.formatMillimes(item.totalMillimes)),
                    ],
                  ),
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 0.5),
                ),
                _buildDetailRow('Total', CurrencyUtils.formatMillimes(sale.totalMillimes), isBold: true),
                _buildDetailRow('Payé', CurrencyUtils.formatMillimes(sale.paidMillimes)),
                if (sale.dueMillimes > 0)
                  _buildDetailRow('Dû', CurrencyUtils.formatMillimes(sale.dueMillimes), color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
            fontSize: isBold ? 15 : 13,
          )),
        ],
      ),
    );
  }
}
