DateTime firstMomentOfMonth(DateTime day) {
  return DateTime(day.year, day.month, 0, 24);
}

DateTime lastDayOfMonth(DateTime day) {
  var lastDayDateTime = (day.month < 12) ? new DateTime(day.year, day.month + 1, 0, 24).subtract(Duration(milliseconds: 1)) : new DateTime(day.year + 1, 1, 0, 24).subtract(Duration(milliseconds: 1));

  return lastDayDateTime;
}

DateTime startOfDay(DateTime day) {
  return DateTime(day.year, day.month, day.day);
}

DateTime endOfDay(DateTime day) {
  return DateTime(day.year, day.month, day.day).add(Duration(days: 1));
}

bool isEmailFormat(String email) {
  RegExp reg = RegExp("[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+");

  return email.contains(reg);
}