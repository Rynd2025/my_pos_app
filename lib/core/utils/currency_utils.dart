import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'DT',
    decimalDigits: 3,
    customPattern: '#,##0.000 ¤',
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Converts double amount (Dinars) to integer millimes (3 decimal places)
  static int toMillimes(double amount) {
    return (amount * 1000).round();
  }

  /// Converts integer millimes to double amount (Dinars)
  static double fromMillimes(int millimes) {
    return millimes / 1000.0;
  }

  static String formatMillimes(int millimes) {
    return format(fromMillimes(millimes));
  }
}
