import 'package:intl/intl.dart';
export 'package:intl/intl.dart';

const maxMonthSupport = 12;
var df = DateFormat("MMM, yyyy");

DateTime nextMonthOf(DateTime time) {
  return monthsAfter(time, 1);
}

DateTime monthsAfter(DateTime time, int months) {
  var month = time.month + 1 * months;
  var year = time.year;

  if (month > 12) {
    month -= 12;
    year += 1;
  }

  return DateTime(year, month, 1);}