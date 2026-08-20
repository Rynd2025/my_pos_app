import '../../../../core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';
import '../../../sales/presentation/bloc/sales_event.dart';
import '../bloc/billing_bloc.dart';

import '../../../sales/domain/entities/sale.dart' as sales;
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../customer/presentation/bloc/customer_event.dart';
import '../../../customer/presentation/bloc/customer_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  sales.PaymentMethod _paymentMethod = sales.PaymentMethod.cash;
  Customer? _selectedCustomer;
  final TextEditingController _newCustomerNameController = TextEditingController();
  final TextEditingController _newCustomerPhoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _newCustomerNameController.dispose();
    _newCustomerPhoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _completeSale(int totalMillimes) {
    int paidMillimes = 0;
    if (_paymentMethod == sales.PaymentMethod.cash) {
      paidMillimes = totalMillimes;
    }

    context.read<BillingBloc>().add(ValidateSale(
          paymentMethod: _paymentMethod,
          customerId: _selectedCustomer?.id,
          paidMillimes: paidMillimes,
        ));
  }

  void _showCustomerPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setPickerState) {
                return BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    final query = _searchController.text.trim().toLowerCase();
                    final filteredCustomers = state.customers.where((c) {
                      if (query.isEmpty) return true;
                      final name = c.name.toLowerCase();
                      final phone = (c.phone ?? '').toLowerCase();
                      return name.contains(query) || phone.contains(query);
                    }).toList();

                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Sélectionner un Client',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Rechercher un client...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setPickerState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (v) {
                              setPickerState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filteredCustomers.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.add)),
                                  title: const Text('Nouveau client',
                                      style: TextStyle(color: Colors.blue)),
                                  onTap: () => _showAddCustomerDialog(setPickerState),
                                );
                              }
                              final customer = filteredCustomers[index - 1];
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(customer.name),
                                subtitle: Text('Tél: ${customer.phone ?? "N/A"} • Dette: ${CurrencyUtils.formatMillimes(customer.balanceMillimes)}'),
                                onTap: () {
                                  setState(() => _selectedCustomer = customer);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            );
          },
        );
      },
    );
  }

  void _showAddCustomerDialog(StateSetter setPickerState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCustomerNameController,
                decoration: const InputDecoration(hintText: 'Nom du client'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newCustomerPhoneController,
                decoration: const InputDecoration(hintText: 'Téléphone (optionnel)'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (_newCustomerNameController.text.isNotEmpty) {
                  final newCustomer = Customer(
                    id: Uuid().v4(),
                    name: _newCustomerNameController.text,
                    phone: _newCustomerPhoneController.text.trim().isEmpty ? null : _newCustomerPhoneController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  context.read<CustomerBloc>().add(AddCustomer(newCustomer));
                  
                  // Optimistically update the picker selection
                  setState(() => _selectedCustomer = newCustomer);
                  
                  _newCustomerNameController.clear();
                  _newCustomerPhoneController.clear();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close sheet
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
        canPop: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Validation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.status == BillingStatus.success) {
                // Sale was validated, refresh global blocs
                context.read<ProductBloc>().add(LoadProducts());
                context.read<SalesBloc>().add(LoadSales());
                
                if (_paymentMethod == sales.PaymentMethod.credit) {
                  context.read<CustomerBloc>().add(LoadCustomers());
                }
                
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vente enregistrée !'),
                    backgroundColor: Colors.blue));
                
                context.pop(); 
              }
            },
            builder: (context, billingState) {
              final totalMillimes = CurrencyUtils.toMillimes(billingState.totalAmount);
              
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside:
                                        BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                                      children: [
                                        _buildHeaderCell('Produit', TextAlign.left),
                                        _buildHeaderCell('Prix', TextAlign.right),
                                        _buildHeaderCell('Total', TextAlign.right),
                                      ],
                                    ),
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell('${item.quantity} x ${item.product.name}', TextAlign.left),
                                          _buildDataCell(CurrencyUtils.format(item.product.price), TextAlign.right, isSubtitle: true),
                                          _buildDataCell(CurrencyUtils.format(item.total), TextAlign.right, isBold: true),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            const Text('MODE DE PAIEMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _paymentMethodButton(
                                    label: 'ESPÈCES',
                                    icon: Icons.money_rounded,
                                    isSelected: _paymentMethod == sales.PaymentMethod.cash,
                                    onTap: () => setState(() => _paymentMethod = sales.PaymentMethod.cash),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _paymentMethodButton(
                                    label: 'CRÉDIT',
                                    icon: Icons.person_search_rounded,
                                    isSelected: _paymentMethod == sales.PaymentMethod.credit,
                                    onTap: () {
                                      setState(() => _paymentMethod = sales.PaymentMethod.credit);
                                      _showCustomerPicker();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            if (_paymentMethod == sales.PaymentMethod.credit && _selectedCustomer != null) ...[
                              const SizedBox(height: 24),
                              const Text('CLIENT SÉLECTIONNÉ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                              const SizedBox(height: 8),
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.person)),
                                  title: Text(_selectedCustomer!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Nouveau solde: ${CurrencyUtils.formatMillimes(_selectedCustomer!.balanceMillimes + totalMillimes)}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _showCustomerPicker,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TOTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                                Text(CurrencyUtils.format(billingState.totalAmount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              onPressed: (billingState.status == BillingStatus.success || (_paymentMethod == sales.PaymentMethod.credit && _selectedCustomer == null)) 
                                  ? null 
                                  : () => _completeSale(totalMillimes),
                              label: billingState.status == BillingStatus.success ? 'VENTE TERMINÉE' : 'ENCAISSER',
                              icon: Icons.check_circle,
                              isLoading: billingState.status == BillingStatus.loading || billingState.isPrinting,
                            ),
                            if (billingState.status == BillingStatus.success)
                              TextButton(
                                onPressed: () {
                                  context.read<BillingBloc>().add(ClearCartEvent());
                                  context.pop();
                                },
                                child: const Text('COMMENCER NOUVELLE VENTE'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _paymentMethodButton({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryColor : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}
