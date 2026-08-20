import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer.dart';
import '../entities/payment.dart';
import '../entities/ledger_entry.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase implements UseCase<List<Customer>, NoParams> {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);
  @override
  Future<Either<Failure, List<Customer>>> call(NoParams params) => repository.getCustomers();
}

class CreateCustomerUseCase implements UseCase<void, Customer> {
  final CustomerRepository repository;
  CreateCustomerUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(Customer params) => repository.createCustomer(params);
}

class UpdateCustomerUseCase implements UseCase<void, Customer> {
  final CustomerRepository repository;
  UpdateCustomerUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(Customer params) => repository.updateCustomer(params);
}

class RecordPaymentUseCase implements UseCase<void, RecordPaymentParams> {
  final CustomerRepository repository;
  RecordPaymentUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(RecordPaymentParams params) => repository.recordPayment(params.payment, params.paymentId);
}

class RecordPaymentParams {
  final Payment payment;
  final String paymentId;
  RecordPaymentParams(this.payment, this.paymentId);
}

class GetCustomerPaymentsUseCase implements UseCase<List<Payment>, String> {
  final CustomerRepository repository;
  GetCustomerPaymentsUseCase(this.repository);
  @override
  Future<Either<Failure, List<Payment>>> call(String customerId) => repository.getPayments(customerId);
}

class GetLedgerUseCase implements UseCase<List<LedgerEntry>, String> {
  final CustomerRepository repository;
  GetLedgerUseCase(this.repository);
  @override
  Future<Either<Failure, List<LedgerEntry>>> call(String customerId) => repository.getLedger(customerId);
}

class AddDebtUseCase implements UseCase<void, AddDebtParams> {
  final CustomerRepository repository;
  AddDebtUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(AddDebtParams params) => repository.addDebt(params.customerId, params.amountMillimes, params.saleId, params.ticketNumber, params.paymentId);
}

class AddDebtParams {
  final String customerId;
  final int amountMillimes;
  final String? saleId;
  final String? ticketNumber;
  final String paymentId;
  AddDebtParams({required this.customerId, required this.amountMillimes, this.saleId, this.ticketNumber, required this.paymentId});
}
