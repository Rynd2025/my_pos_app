import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';
import '../models/payment_model.dart';
import '../models/ledger_entry_model.dart';

import '../../../../core/utils/normalization_utils.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final box = HiveDatabase.customerBox;
      final customers = box.values.map((m) => m.toEntity()).toList();
      return Right(customers);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomer(String id) async {
    try {
      final box = HiveDatabase.customerBox;
      final model = box.get(id);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(CacheFailure('Customer not found'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCustomer(Customer customer) async {
    try {
      final box = HiveDatabase.customerBox;
      
      // Check for duplicates
      final normalizedNewName = NormalizationUtils.normalizeName(customer.name);
      final normalizedNewPhone = NormalizationUtils.normalizePhone(customer.phone);
      
      final isDuplicate = box.values.any((m) {
        final normalizedName = NormalizationUtils.normalizeName(m.name);
        final normalizedPhone = NormalizationUtils.normalizePhone(m.phone);
        return normalizedName == normalizedNewName && normalizedPhone == normalizedNewPhone;
      });
      
      if (isDuplicate) {
        return const Left(CacheFailure('Ce client existe déjà.'));
      }

      await box.put(customer.id, CustomerModel.fromEntity(customer));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer(Customer customer) async {
    try {
      final box = HiveDatabase.customerBox;
      await box.put(customer.id, CustomerModel.fromEntity(customer));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPayments(String customerId) async {
    try {
      final box = HiveDatabase.paymentBox;
      final payments = box.values
          .where((m) => m.customerId == customerId)
          .map((m) => m.toEntity())
          .toList();
      return Right(payments);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordPayment(Payment payment, String paymentId) async {
    try {
      final paymentBox = HiveDatabase.paymentBox;
      final customerBox = HiveDatabase.customerBox;
      final ledgerBox = HiveDatabase.ledgerBox;

      // Update customer balance
      final customerModel = customerBox.get(payment.customerId);
      if (customerModel == null) return const Left(CacheFailure('Client non trouvé'));

      final newBalance = customerModel.balanceMillimes - payment.amountMillimes;
      final updatedCustomer = customerModel.copyWith(balanceMillimes: newBalance);

      // Save payment
      await paymentBox.put(payment.id, PaymentModel.fromEntity(payment));

      // Add to ledger
      final ledgerEntry = LedgerEntry(
        id: Uuid().v4(),
        paymentId: paymentId,
        customerId: payment.customerId,
        saleId: payment.saleId,
        type: LedgerEntryType.payment,
        amountMillimes: -payment.amountMillimes,
        createdAt: payment.createdAt,
        note: payment.note,
        balanceAfter: newBalance,
      );
      await ledgerBox.put(ledgerEntry.id, LedgerEntryModel.fromEntity(ledgerEntry));
      await customerBox.put(updatedCustomer.id, CustomerModel.fromEntity(updatedCustomer));

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addDebt(String customerId, int amountMillimes, String? saleId, String? ticketNumber, String paymentId) async {
    try {
      final customerBox = HiveDatabase.customerBox;
      final ledgerBox = HiveDatabase.ledgerBox;

      final customerModel = customerBox.get(customerId);
      if (customerModel == null) return const Left(CacheFailure('Client non trouvé'));

      final newBalance = customerModel.balanceMillimes + amountMillimes;
      final updatedCustomer = customerModel.copyWith(balanceMillimes: newBalance);

      // Add to ledger
      final ledgerEntry = LedgerEntry(
        id: Uuid().v4(),
        paymentId: paymentId,
        customerId: customerId,
        saleId: saleId,
        ticketNumber: ticketNumber,
        type: LedgerEntryType.creditSale,
        amountMillimes: amountMillimes,
        createdAt: DateTime.now(),
        balanceAfter: newBalance,
      );
      await ledgerBox.put(ledgerEntry.id, LedgerEntryModel.fromEntity(ledgerEntry));
      await customerBox.put(updatedCustomer.id, CustomerModel.fromEntity(updatedCustomer));

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LedgerEntry>>> getLedger(String customerId) async {
    try {
      final box = HiveDatabase.ledgerBox;
      final entries = box.values
          .where((m) => m.customerId == customerId)
          .map((m) => m.toEntity())
          .toList();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(entries);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
