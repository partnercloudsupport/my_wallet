import 'package:intl/intl.dart';
export 'package:intl/intl.dart';

var df = DateFormat("MMM, yyyy");

enum Month {
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December,
}

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