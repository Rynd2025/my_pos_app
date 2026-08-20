import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/sale_usecases.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSalesUseCase getSalesUseCase;

  SalesBloc({
    required this.getSalesUseCase,
  }) : super(const SalesState()) {
    on<LoadSales>(_onLoadSales);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SalesState> emit) async {
    emit(state.copyWith(status: SalesStatus.loading));
    final result = await getSalesUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: SalesStatus.error, message: failure.message)),
      (sales) => emit(state.copyWith(status: SalesStatus.loaded, sales: sales)),
    );
  }
}
