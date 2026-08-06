import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/sale_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSalesUseCase getSalesUseCase;

  SalesBloc({required this.getSalesUseCase}) : super(SalesInitial()) {
    on<LoadSalesEvent>(_onLoadSales);
  }

  Future<void> _onLoadSales(LoadSalesEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    final result = await getSalesUseCase(NoParams());
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }
}
