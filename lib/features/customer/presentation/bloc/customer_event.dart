import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/payment.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class AddCustomer extends CustomerEvent {
  final Customer customer;
  const AddCustomer(this.customer);
  @override
  List<Object> get props => [customer];
}

class SelectCustomer extends CustomerEvent {
  final Customer? customer;
  const SelectCustomer(this.customer);
  @override
  List<Object?> get props => [customer];
}

class RecordCustomerPayment extends CustomerEvent {
  final Payment payment;
  const RecordCustomerPayment(this.payment);
  @override
  List<Object> get props => [payment];
}

class LoadCustomerLedger extends CustomerEvent {
  final String customerId;
  const LoadCustomerLedger(this.customerId);
  @override
  List<Object> get props => [customerId];
}
