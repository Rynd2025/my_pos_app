import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/customer.dart';
import '../../../../core/utils/normalization_utils.dart';
import 'package:uuid/uuid.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients & Crédits'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading && state.customers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                var filteredCustomers = state.customers.where((c) {
                  final nameMatch = c.name.toLowerCase().contains(_searchQuery);
                  final phoneMatch = (c.phone ?? '').contains(_searchQuery);
                  return nameMatch || phoneMatch;
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(child: Text('Aucun client trouvé'));
                }

                // Sort: debt first, then name
                filteredCustomers.sort((a, b) {
                  if (a.balanceMillimes != b.balanceMillimes) {
                    return b.balanceMillimes.compareTo(a.balanceMillimes);
                  }
                  return a.name.compareTo(b.name);
                });

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(customer.phone ?? 'Pas de téléphone'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Dette', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            CurrencyUtils.formatMillimes(customer.balanceMillimes),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: customer.balanceMillimes > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => context.push('/customers/${customer.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nom du client'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(hintText: 'Téléphone (optionnel)'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newCustomer = Customer(
                    id: Uuid().v4(),
                    name: nameController.text,
                    phone: phoneController.text.isEmpty ? null : phoneController.text,
                  );
                  context.read<CustomerBloc>().add(AddCustomer(newCustomer));
                  Navigator.pop(context);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }
}
