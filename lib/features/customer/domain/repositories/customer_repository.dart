import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../entities/payment.dart';
import '../entities/ledger_entry.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, Customer>> getCustomer(String id);
  Future<Either<Failure, void>> createCustomer(Customer customer);
  Future<Either<Failure, void>> updateCustomer(Customer customer);
  Future<Either<Failure, List<Payment>>> getPayments(String customerId);
  Future<Either<Failure, void>> recordPayment(Payment payment, String paymentId);
  Future<Either<Failure, void>> addDebt(String customerId, int amountMillimes, String? saleId, String? ticketNumber, String paymentId);
  Future<Either<Failure, List<LedgerEntry>>> getLedger(String customerId);
}
