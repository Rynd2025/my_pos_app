import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/customer_usecases.dart';
import 'customer_event.dart';
import 'customer_state.dart';

import '../../domain/entities/ledger_entry.dart';

import '../../../../core/utils/id_generator.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final RecordPaymentUseCase recordPaymentUseCase;
  final GetLedgerUseCase getLedgerUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.createCustomerUseCase,
    required this.recordPaymentUseCase,
    required this.getLedgerUseCase,
  }) : super(const CustomerState()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<SelectCustomer>(_onSelectCustomer);
    on<RecordCustomerPayment>(_onRecordCustomerPayment);
    on<LoadCustomerLedger>(_onLoadCustomerLedger);
  }

  Future<void> _onLoadCustomerLedger(LoadCustomerLedger event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await getLedgerUseCase(event.customerId);
    result.fold(
      (failure) => emit(state.copyWith(status: CustomerStatus.error, message: failure.message)),
      (entries) => emit(state.copyWith(status: CustomerStatus.loaded, ledger: entries)),
    );
  }

  Future<void> _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await getCustomersUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: CustomerStatus.error, message: failure.message)),
      (customers) => emit(state.copyWith(status: CustomerStatus.loaded, customers: customers)),
    );
  }

  Future<void> _onAddCustomer(AddCustomer event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await createCustomerUseCase(event.customer);
    result.fold(
      (failure) {
        if (failure.message == 'Ce client existe déjà.') {
          // If customer exists, we might want to find it and select it
          // For now just error
          emit(state.copyWith(status: CustomerStatus.error, message: failure.message));
        } else {
          emit(state.copyWith(status: CustomerStatus.error, message: failure.message));
        }
      },
      (_) {
        add(LoadCustomers());
        emit(state.copyWith(status: CustomerStatus.success, selectedCustomer: event.customer, message: 'Client créé avec succès'));
      },
    );
  }

  void _onSelectCustomer(SelectCustomer event, Emitter<CustomerState> emit) {
    emit(state.copyWith(selectedCustomer: event.customer, clearSelectedCustomer: event.customer == null));
  }

  Future<void> _onRecordCustomerPayment(RecordCustomerPayment event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    // Generate a paymentId for manual repayment
    final dateStr = DateTime.now().millisecondsSinceEpoch.toString();
    final paymentId = 'PAY-MANUAL-$dateStr';
    
    final result = await recordPaymentUseCase(RecordPaymentParams(event.payment, paymentId));
    result.fold(
      (failure) => emit(state.copyWith(status: CustomerStatus.error, message: failure.message)),
      (_) {
        add(LoadCustomers());
        emit(state.copyWith(status: CustomerStatus.success, message: 'Paiement enregistré avec succès'));
      },
    );
  }
}
