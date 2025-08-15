import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatTime12h(DateTime time) {
    final local = time.toLocal();
    final formatter = DateFormat('hh:mm a');
    return formatter.format(local);
  }

  static String formatDayMonth(DateTime date) {
    final local = date.toLocal();
    final formatter = DateFormat('EEEE, d MMMM');
    return formatter.format(local);
  }
}
