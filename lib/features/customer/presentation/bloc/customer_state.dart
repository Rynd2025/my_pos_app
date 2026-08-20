import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

import '../../domain/entities/ledger_entry.dart';

enum CustomerStatus { initial, loading, loaded, success, error }

class CustomerState extends Equatable {
  final CustomerStatus status;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final List<LedgerEntry> ledger;
  final String? message;

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.selectedCustomer,
    this.ledger = const [],
    this.message,
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<Customer>? customers,
    Customer? selectedCustomer,
    List<LedgerEntry>? ledger,
    String? message,
    bool clearSelectedCustomer = false,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      selectedCustomer: clearSelectedCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      ledger: ledger ?? this.ledger,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, customers, selectedCustomer, ledger, message];
}
