
import 'package:intl/intl.dart';

class Utils {
  static String formatCurrency(int value) {
    final double doubleValue = value.toDouble();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(doubleValue);
  }
}
