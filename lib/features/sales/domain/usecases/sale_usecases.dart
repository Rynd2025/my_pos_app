import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class GetSalesUseCase implements UseCase<List<Sale>, NoParams> {
  final SaleRepository repository;
  GetSalesUseCase(this.repository);
  @override
  Future<Either<Failure, List<Sale>>> call(NoParams params) => repository.getSales();
}

class SaveSaleUseCase implements UseCase<void, Sale> {
  final SaleRepository repository;
  SaveSaleUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(Sale params) => repository.saveSale(params);
}

class GetNextTicketNumberUseCase implements UseCase<String, NoParams> {
  final SaleRepository repository;
  GetNextTicketNumberUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(NoParams params) => repository.getNextTicketNumber();
}
