import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';
import '../../../sales/presentation/bloc/sales_event.dart';
import '../../../sales/presentation/bloc/sales_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../../sales/domain/entities/sale.dart';
import 'package:uuid/uuid.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String customerId;
  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final TextEditingController _paymentAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<CustomerBloc>().add(LoadCustomerLedger(widget.customerId));
    context.read<SalesBloc>().add(LoadSales()); // Load sales to find details for credit entries
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state.status == CustomerStatus.success) {
              context.read<CustomerBloc>().add(LoadCustomerLedger(widget.customerId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Opération réussie'), backgroundColor: Colors.green)
              );
            } else if (state.status == CustomerStatus.error && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!), backgroundColor: Colors.red)
              );
            }
          },
        ),
      ],
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          final customerIndex = state.customers.indexWhere((c) => c.id == widget.customerId);
          if (customerIndex == -1) {
             return Scaffold(appBar: AppBar(), body: const Center(child: Text('Client non trouvé')));
          }
          final customer = state.customers[customerIndex];
          
          return Scaffold(
            appBar: AppBar(
              title: Text(customer.name),
            ),
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      const Text('DETTE ACTUELLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyUtils.formatMillimes(customer.balanceMillimes),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: customer.balanceMillimes > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: customer.balanceMillimes > 0 ? () => _showRepaymentDialog(context, customer.balanceMillimes) : null,
                          icon: const Icon(Icons.add_card),
                          label: const Text('ENCAISSER UN PAIEMENT'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('HISTORIQUE DES TRANSACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                ),
                Expanded(
                  child: _buildTransactionHistory(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, CustomerState customerState) {
    if (customerState.status == CustomerStatus.loading && customerState.ledger.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (customerState.ledger.isEmpty) {
      return const Center(child: Text('Aucune transaction'));
    }

    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, salesState) {
        return ListView.builder(
          itemCount: customerState.ledger.length,
          itemBuilder: (context, index) {
            final entry = customerState.ledger[index];
            final isPayment = entry.type == LedgerEntryType.payment;
            
            // Try to find the associated sale items
            Sale? sale;
            if (!isPayment && entry.saleId != null) {
               sale = salesState.sales.where((s) => s.id == entry.saleId).firstOrNull;
            }

            if (isPayment) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  child: const Icon(Icons.payment, color: Colors.green),
                ),
                title: const Text('Paiement reçu', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(entry.createdAt)),
                trailing: Text(
                  CurrencyUtils.formatMillimes(entry.amountMillimes),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  child: const Icon(Icons.shopping_bag, color: Colors.orange),
                ),
                title: Text(entry.ticketNumber ?? 'Vente à crédit', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(entry.createdAt)),
                trailing: Text(
                  '+${CurrencyUtils.formatMillimes(entry.amountMillimes)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sale != null) ...[
                           ...sale.items.map((item) => Padding(
                             padding: const EdgeInsets.symmetric(vertical: 2.0),
                             child: Row(
                               children: [
                                 Text('${item.quantity}x ', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                 Expanded(child: Text(item.productName)),
                                 Text(CurrencyUtils.formatMillimes(item.totalMillimes)),
                               ],
                             ),
                           )),
                           const Divider(),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Solde après:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(CurrencyUtils.formatMillimes(entry.balanceAfter), 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('Ref: ${entry.paymentId}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRepaymentDialog(BuildContext context, int currentDebt) {
    _paymentAmountController.text = CurrencyUtils.fromMillimes(currentDebt).toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Encaisser Paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dette actuelle: ${CurrencyUtils.formatMillimes(currentDebt)}'),
              const SizedBox(height: 16),
              TextField(
                controller: _paymentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Montant reçu (DT)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final amountDT = double.tryParse(_paymentAmountController.text);
                if (amountDT != null && amountDT > 0) {
                  final payment = Payment(
                    id: Uuid().v4(),
                    customerId: widget.customerId,
                    amountMillimes: CurrencyUtils.toMillimes(amountDT),
                    createdAt: DateTime.now(),
                  );
                  context.read<CustomerBloc>().add(RecordCustomerPayment(payment));
                  Navigator.pop(context);
                }
              },
              child: const Text('ENCAISSER'),
            ),
          ],
        );
      },
    );
  }
}
