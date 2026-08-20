import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';

abstract class ProductImportRepository {
  Stream<double> importTunisianProducts();
}
