
import 'package:intl/intl.dart';

class Utils {
  static String formatCurrency(int value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(value);
  }
}
