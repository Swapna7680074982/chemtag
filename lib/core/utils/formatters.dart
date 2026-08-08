import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static final DateFormat dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat timeFormat = DateFormat('hh:mm a');

  static String formatCurrency(double amount) {
    return currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return dateTimeFormat.format(date);
  }

  static String formatLatLng(double lat, double lng) {
    return '${lat.toStringAsFixed(5)}°, ${lng.toStringAsFixed(5)}°';
  }
}
