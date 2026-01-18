import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _format = NumberFormat("#,##0.00", "en_US");

  static String format(double amount) {
    return _format.format(amount);
  }
}
