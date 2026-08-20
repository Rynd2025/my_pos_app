import 'package:intl/intl.dart';

class IdGenerator {
  static String generatePaymentId(String ticketNumber) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    // Remove # or TKT- from ticketNumber
    final cleanTicket = ticketNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return 'PAY-$date-$cleanTicket';
  }
}
