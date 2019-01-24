import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_wallet/data/data.dart';
import 'package:synchronized/synchronized.dart';
import 'package:my_wallet/data/data_observer.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:flutter/foundation.dart';

// #############################################################################################################################
// database manager
// #############################################################################################################################
final _id = "_id";
final _updated = "_updated";

// table Account
final _tableAccounts = tableAccount;
final _accName = "_name";
final _accInitialBalance = "_initialBalance";
final _accCreated = "_created";
final _accType = "_type";
final _accCurrency = "_currency";
final _accBalance = "_balance";
final _accSpent = "_spent";
final _accEarned = "_earned";

// table transaction
final _tableTransactions = tableTransactions;
final _transDateTime = "_dateTime";
final _transAcc = "_accountId";
final _transCategory = "_categoryId";
final _transAmount = "_amount";
final _transDesc = "_transactionDescription";
final _transType = "_transactionType";
final _transUid = "_transactionUserUid";

// table category
final _tableCategory = tableCategory;
final _catName = "_name";
final _catColorHex = "_colorHex";
final _catCategoryType = "_type";

// table budget
final _tableBudget = tableBudget;
final _budgetCategoryId = "_catId";
final _budgetPerMonth = "_budgetPerMonth";
final _budgetStart = "_budgetStart";
final _budgetEnd = "_budgetEnd";

final _tableUser = tableUser;
final _userDisplayName = "_displayName";
final _userEmail = "_email";
final _userPhotoUrl = "_photoUrl";
final _userColor = "_userColor";
final _userVerified = "_userVerified";

// table money transfer
final _tableTransfer = tableTransfer;
final _transferFrom = "_transferFrom";
final _transferTo = "_transferTo";
final _transferAmount = "_transferAmount";
final _transferDate = "_date";
final _transferUuid = "_uuid";

// table discharge liability
final _tableDischargeLiability = tableDischargeLiability;
final _dischargeDateTime = "_dateTime";
final _dischargeFromAcc = "_accountId";
final _dischargeLiabilityId = "_liabilityId";
final _dischargeCategory = "_categoryId";
final _dischargeAmount = "_amount";
final _dischargeUid = "_dischargeUserUid";

_Database db = _Database();

Map<String, String> _tableMap = {
  "Account" : _tableAccounts,
  "Transaction": _tableTransactions,
  "Category" : _tableCategory,
  "User" : _tableUser,
  "Budget" : _tableBudget,
  "Transfer" : _tableTransfer
};

void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  db.registerDatabaseObservable(tables, observable);
}

void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  db.unregisterDatabaseObservable(tables, observable);
}

Future<void> init() {
  return db.init();
}

Future<void> resume() {
  return init();
}

Future<void> dispose() {
  return db.dispose();
}

Future<List<String>> queryOutOfSync(String table) async {
  var result = <String> [];

  do {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  var pausedTime = sharedPreferences.getInt(prefPausedTime);
  if (pausedTime == null) break;

  var dbTable = _tableMap[table];
  if (dbTable == null) break;

  var map = await db._query(dbTable, where: "$_updated <= $pausedTime", columns: [_id]);

  if(map == null) break;

  if(map.isEmpty) break;

  result = map.map((f) => "${f[_id]}").toList();

  } while (false);

  return result;
}
// ------------------------------------------------------------------------------------------------------------------------
// other SQL helper methods
Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type, {int accountId, int categoryId}) async {
  var amount = 0.0;

  // query from transaction table
      {
    var dateQuery = "($_transDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch})";
    var transactionTypeQuery = "$_transType IN ${type.map((f) => "${f.id}").toString()}";

    // additional queries
    var accountQuery = "";
    var categoryQuery = "";

    if (accountId != null) accountQuery = " AND $_transAcc = $accountId";
    if (categoryId != null) categoryQuery = " AND $_transCategory = $categoryId";

    var sum = await db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE $dateQuery AND $transactionTypeQuery$accountQuery$categoryQuery");
    amount += sum[0].values.first ?? 0.0;
  }

  return amount;
}

Future<double> sumAllAccountBalance({List<AccountType> types}) async {
  var where = "";

  if (types != null && types.isNotEmpty) {
    var typeWhere = types.map((f) => "${f.id}").toString();

    where = " WHERE $_accType in $typeWhere";
  }

  var sum = await db._executeSql("SELECT SUM($_accBalance) FROM $_tableAccounts$where");

  return sum[0].values.first ?? 0.0;
}

Future<List<T>> queryCategoryWithBudgetAndTransactionsForMonth<T>(DateTime month, Function(AppCategory cat, double budgetPerMonth, double spent, double earn) conversion) async {
  List<T> result = [];

  List<Map<String, dynamic>> cats = await db._query(_tableCategory);

  DateTime firstDay = Utils.firstMomentOfMonth(month);
  DateTime lastDay = Utils.lastDayOfMonth(month);

  if(cats != null) {
    for(Map<String, dynamic> f in cats) {
      var category = _toCategory(f);

      var findBudget = _compileFindBudgetSqlQuery(firstDay.millisecondsSinceEpoch, lastDay.millisecondsSinceEpoch);
      var rawBudgetPerMonth = await db._executeSql(
          """
               SELECT SUM($_budgetPerMonth)
               FROM $_tableBudget
                WHERE $_budgetCategoryId = ${category.id} AND $findBudget
                """);

      var rawSpend = await db._executeSql(
          """
            SELECT SUM($_transAmount) 
            FROM $_tableTransactions
            WHERE $_transCategory = ${category.id}
            AND ($_transDateTime BETWEEN ${firstDay.millisecondsSinceEpoch} AND ${lastDay.millisecondsSinceEpoch})
            AND $_transType in ${TransactionType.typeExpense.map((f) => "${f.id}").toString()}
          """
      );
      var rawEarn = await db._executeSql(
          """
          SELECT SUM($_transAmount) 
            FROM $_tableTransactions
            WHERE $_transCategory = ${category.id}
            AND ($_transDateTime BETWEEN ${firstDay.millisecondsSinceEpoch} AND ${lastDay.millisecondsSinceEpoch})
            AND $_transType in ${TransactionType.typeIncome.map((f) => "${f.id}").toString()}
          """
      );

      var spent = rawSpend.first.values.first ?? 0.0;
      var earn = rawEarn.first.values.first ?? 0.0;
      var budgetPerMonth = rawBudgetPerMonth.first.values.first ?? 0.0;

      result.add(conversion(category, budgetPerMonth, spent, earn));
    }
  }

  return result;
}

Future<double> sumTransactionsByDay(DateTime day, TransactionType type) async {
    var startOfDay = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    var endOfDay = DateTime(day.year, day.month, day.day + 1).millisecondsSinceEpoch;

    var sum = await db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN $startOfDay AND $endOfDay) AND $_transType = ${type.id}");

    return sum[0].values.first ?? 0.0;
}

Future<double> sumTransactionsByCategory({@required int catId, @required List<TransactionType> type, @required DateTime start, @required DateTime end}) async {
  String types = type.map((f) => "${f.id}").toString();
  var sum = await db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}) AND $_transCategory = $catId AND $_transType in $types");

  return sum[0].values.first ?? 0.0;
}

Future<double> sumAllBudget(DateTime start, DateTime end) async {
  var sum = await db._executeSql("SELECT SUM($_budgetPerMonth) FROM $_tableBudget WHERE ${_compileFindBudgetSqlQuery(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch)}");
  return sum[0].values.first ?? 0.0;
}

// ------------------------------------------------------------------------------------------------------------------------
// Queries
Future<List<Account>> queryAccounts({int id, AccountType type}) async {
  if (id != null && type != null) {
    throw Exception("At most 1 option can be queried at the same time");
  }

  String where;
  List whereArgs;

  if (type != null) {
    where = "$_accType = ?";
    whereArgs = [type.id];
  } else if (id != null) {
    where = "$_id = ?";
    whereArgs = [id];
  } else {
    where = null;
    whereArgs = null;
  }

  List<Map<String, dynamic>> map = await db._query(_tableAccounts, where: where, whereArgs: whereArgs);

  if (map != null) {
    return map.map((f) => _toAccount(f)).toList();
  }

  return null;
}

Future<List<Account>> queryAccountsExcept(List<int> exceptAccountId) async {
  if(exceptAccountId == null || exceptAccountId.isEmpty) throw Exception("No list of account IDs to exclude");

  String where = "$_id NOT IN ${exceptAccountId.map((f) => "$f").toString()}";

  List<Map<String, dynamic>> map = await db._query(_tableAccounts, where: where);

  if (map != null) {
    return map.map((f) => _toAccount(f)).toList();
  }

  return null;

}
Future<List<AppTransaction>> queryTransactions({int id}) async {
  String where;

  if(id != null) where = "$_id = $id";

  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: where);

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionsBetweenDates(DateTime from, DateTime to, {TransactionType type}) async {
  String where = from != null && to != null ? "$_transDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}" : null;

  if(type != null) {
    where = "($where) AND $_transType = ${type.id}";
  }

  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: where);

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForCategory(int categoryId, DateTime day) async {
  var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
  var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: "$_transCategory = $categoryId AND ($_transDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})");

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryAllTransactionForCategory(int categoryId) async {
  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: "$_transCategory = $categoryId");

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForAccount(int accountId, DateTime day) async {
  var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
  var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: "$_transAcc = $accountId AND ($_transDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})");

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<Transfer>> queryTransfer({int account, DateTime day}) async {
  String query = "";

  if(day != null) {
    var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
    var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

    query = "($_transferDate BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})";
  }

  if(account != null) {
    query = "${query == null || query.isEmpty ? "" : "$query AND "}($_transferFrom = $account OR $_transferTo = $account)";
  }

  List<Map<String, dynamic>> map = await db._query(_tableTransfer, where: "$query");

  return map == null ? [] : map.map((f) => _toTransfer(f)).toList();
}

Future<List<DischargeOfLiability>> queryDischargeOfLiability({int account, DateTime day}) async {
  var query = "";
  if(day != null) {
    var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
    var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

    query = "($_dischargeDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})";
  }

  if(account != null) {
    query = "${query == null || query.isEmpty ? "" : "$query AND "}($_dischargeLiabilityId = $account OR $_dischargeFromAcc = $account)";
  }

  List<Map<String, dynamic>> map = await db._query(_tableDischargeLiability, where: "$query");

  return map == null ? [] : map.map((f) => _toDischargeOfLiability(f)).toList();
}

Future<List<AppTransaction>> queryAllTransactionForAccount(int accountId) async {

  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: "$_transAcc = $accountId");

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<DateTime>> findTransactionsDates(DateTime day, {int accountId, int categoryId}) async {
  Map<DateTime, DateTime> dates = {};

  DateTime start = Utils.firstMomentOfMonth(day == null ? DateTime.now() : day);
  DateTime end = Utils.lastDayOfMonth(day == null ? DateTime.now() : day);

  // transaction table
  {
    String where;

    String dateWhere = "($_transDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch})";

    if(accountId != null) where = "$_transAcc = $accountId";
    if(categoryId != null) where = "${where != null ? "$where AND " : ""}$_transCategory = $categoryId";

    where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

    List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: where, columns: [_transDateTime]);

    if(map != null && map.isNotEmpty) {
      map.forEach((f) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(f[_transDateTime]));

        dates.putIfAbsent(date, () => date);
      });
    }
  }

  // transfer table
  if(categoryId == null || accountId !=  null){
    String where;

    String dateWhere = "$_transferDate BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}";

    if(accountId != null) where = "($_transferFrom = $accountId OR $_transferTo = $accountId)";

    where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

    List<Map<String, dynamic>> map = await db._query(_tableTransfer, where: where, columns: [_transferDate]);

    if(map != null && map.isNotEmpty) {
      map.forEach((f) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(f[_transferDate]));

        dates.putIfAbsent(date, () => date);
      });
    }
  }

  // discharge liability table
  if(accountId != null || (accountId == null && categoryId == null)){
    String where;

    String dateWhere = "$_dischargeDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}";

    if(accountId != null) where = "($_dischargeFromAcc = $accountId OR $_dischargeLiabilityId = $accountId)";
    if(categoryId != null) where = "${where != null ? "$where AND " : ""}$_dischargeCategory = $categoryId";

    where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

    List<Map<String, dynamic>> map = await db._query(_tableDischargeLiability, where: where, columns: [_dischargeDateTime]);

    if(map != null && map.isNotEmpty) {
      map.forEach((f) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(f[_dischargeDateTime]));

        dates.putIfAbsent(date, () => date);
      });
    }
  }

  return dates.keys.toList();
}

Future<List<AppCategory>> queryCategory({int id, CategoryType type}) async {
  String where;
  List<int> whereArg;

  if (id == null && type == null) {
    where = null;
    whereArg = null;
  } else if(id != null) {
    where = "$_id = ?";
    whereArg = [id];
  } else if(type != null) {
    where = "$_catCategoryType = ?";
    whereArg = [type.id];
  }
  List<Map<String, dynamic>> map = await db._query(_tableCategory, where: where, whereArgs: whereArg);

  if (map != null) return map.map((f) => _toCategory(f)).toList();

  return null;
}

Future<List<AppCategory>> queryCategoryWithTransaction({DateTime from, DateTime to, List<TransactionType> type, bool filterZero = false, bool orderByType = false}) async {
  String where;
  int _from = 0;
  int _to = DateTime.now().millisecondsSinceEpoch;

  if (from != null) {
    _from = from.millisecondsSinceEpoch;
  }

  if (to != null) {
    _to = to.millisecondsSinceEpoch;
  }
  where = "$_transDateTime BETWEEN $_from AND $_to";

  if(type != null) {
    var types = type.map((f) => "${f.id}").toString();
    where = "($where) AND ($_transType IN $types)";
  }

    String sqlCategory = "SELECT * FROM $_tableCategory";
    List<AppCategory> appCat = [];

    List<Map<String, dynamic>> catMaps = await db._executeSql(sqlCategory);

    if(catMaps != null && catMaps.isNotEmpty) {
      for(Map<String, dynamic> category in catMaps) {
        int categoryId = category[_id];

        if(categoryId != null) {
          String sqlIncome = "SELECT SUM($_transAmount) as income FROM $_tableTransactions WHERE $_transCategory = $categoryId AND $where AND ($_transType IN ${TransactionType.typeIncome.map((f) => "${f.id}").toString()})";
          String sqlExpense = "SELECT SUM($_transAmount) as expense FROM $_tableTransactions WHERE $_transCategory = $categoryId AND $where AND ($_transType IN ${TransactionType.typeExpense.map((f) => "${f.id}").toString()})";

          var incomeMap = await db._executeSql(sqlIncome);
          var expenseMap = await db._executeSql(sqlExpense);

          var income = 0.0;
          var expense = 0.0;

          if(incomeMap != null && incomeMap.isNotEmpty && incomeMap.first != null && incomeMap.first.values != null && incomeMap.first.values.first != null) income = incomeMap.first.values.first;
          if(expenseMap != null && expenseMap.isNotEmpty && expenseMap.first != null && expenseMap.first.values != null && expenseMap.first.values.first != null) expense = expenseMap.first.values.first;

          var appCategory = _toCategory(category);
          appCategory.income = income ?? 0.0;
          appCategory.expense = expense ?? 0.0;

          if(!filterZero) appCat.add(appCategory);
          else if(income > 0 || expense > 0) appCat.add(appCategory);
        }
      }
    }

  if(orderByType && type != null) {
    if(type == TransactionType.typeExpense) {
      // sort by expenses
      appCat.sort((a, b) => b.expense.floor() - a.expense.floor());
    } else if(type == TransactionType.typeIncome) {
      // sort by income
      appCat.sort((a, b) => b.income.floor() - a.income.floor());
    }
  }

    // no category found, return empty list;
    return appCat;
}

Future<List<AppTransaction>> queryForDate(DateTime day) async {
  DateTime startOfDay = DateTime(day.year, day.month, day.day, 0, 0);

  List<Map<String, dynamic>> map = await db._query(_tableTransactions, where: "$_transDateTime BETWEEN ? AND ?", whereArgs: [startOfDay.millisecondsSinceEpoch, startOfDay.add(Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999)).millisecondsSinceEpoch]);

  return map != null ? map.map((f) => _toTransaction(f)).toList() : null;
}

Future<List<User>> queryUser({String uuid}) async {
  String where;
  List whereArgs;

  if(uuid != null) {
    where = "$_id = ?";
    whereArgs = [uuid];
  }
  List<Map<String, dynamic>> map = await db._query(_tableUser, where: where, whereArgs: whereArgs);

  return map == null ? null : map.map((f) => _toUser(f)).toList();
}

Future<List<Budget>> queryBudgets() async {
  List<Map<String, dynamic>> map = await db._query(_tableBudget);

  return map == null ? null : map.map((f) => _toBudget(f)).toList();
}

Future<DateTime> queryMinBudgetStart() async {
  var min = await db._executeSql("SELECT MIN($_budgetStart) FROM $_tableBudget");

  return min == null || min[0].values == null || min[0].values.first == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(min[0].values.first);
}

Future<DateTime> queryMaxBudgetEnd() async {
  var max = await db._executeSql("SELECT MAX($_budgetEnd) FROM $_tableBudget");

  return max == null || max[0].values == null || max[0].values.first == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(max[0].values.first);
}

Future<Budget> findBudget({int catId, DateTime start, DateTime end}) async {
  var monthStart = Utils.firstMomentOfMonth(start).millisecondsSinceEpoch;
  var monthEnd = end == null ? null : Utils.lastDayOfMonth(end).millisecondsSinceEpoch;

  var findBudget = "";

  var findCategory = "";
  if(catId != null) findCategory = "$_budgetCategoryId = $catId AND ";

  findBudget = _compileFindBudgetSqlQuery(monthStart, monthEnd);

    var listMap = await db._query(_tableBudget, where: "$findCategory$findBudget", );

    if(listMap != null && listMap.isNotEmpty) {
      var budget = _toBudget(listMap.first);
      return budget;
    }
    return null;
}

Future<double> querySumAllBudgetForMonth(DateTime start, DateTime end) async {
  var monthStart = Utils.firstMomentOfMonth(start).millisecondsSinceEpoch;
  var monthEnd = end == null ? null : Utils.lastDayOfMonth(end).millisecondsSinceEpoch;

  var findBudget = "";

  findBudget = _compileFindBudgetSqlQuery(monthStart, monthEnd);

  var listMap = await db._query(_tableBudget, where: "$findBudget", columns: [ 'SUM($_budgetPerMonth)']);

  double amount = listMap.first.values.first ?? 0.0;
  return amount;
}

/// Find budget IDs for this category with start/end time, which means any budget with duration collapse with this duration
/// There can be multiple ID returns, incase there are multiple budgets fall that cover the period between start and end time.
/// Cases
///     - 0 ID is returned: create new budget
///     - more IDs are returned: Update the first budget, and delete other collapsing budgets
Future<List<Budget>> findCollapsingBudgets({@required int catId, @required DateTime start, @required DateTime end}) async {
  int monthStart = Utils.firstMomentOfMonth(start == null ? DateTime.now() : start).millisecondsSinceEpoch;
  int monthEnd = end == null ? null : Utils.lastDayOfMonth(end).millisecondsSinceEpoch;
  String findBudget = _compileFindBudgetSqlQuery(monthStart, monthEnd);

  // additional case when $start is before $monthStart, and endDate is null
  // is this special case for budget coverage, not to be used in other budget query
  findBudget += " OR ($monthStart <= $_budgetStart${monthEnd == null ? "" : " AND $_budgetEnd >= $monthEnd"})";

  var map = await db._query(_tableBudget, where: "$_budgetCategoryId = $catId AND ($findBudget)",);

  return map == null ? [] : map.map((f) => _toBudget(f)).toList();
}

Future<List<Budget>> findAllBudgetForCategory(int catId) async {
  var listMap = await db._query(_tableBudget, where: "$_budgetCategoryId = $catId");

  return listMap == null || listMap.isEmpty ? null : listMap.map((f) => _toBudget(f)).toList();
}

Future<int> generateAccountId() {
  return db._generateId(_tableAccounts);
}

Future<int> generateTransactionId() {
  return db._generateId(_tableTransactions);
}

Future<int> generateCategoryId() {
  return db._generateId(_tableCategory);
}

Future<int> generateBudgetId() {
  return db._generateId(_tableBudget);
}

Future<int> generateTransferId() {
  return db._generateId(_tableTransfer);
}

Future<int> generateDischargeLiabilityId() {
  return db._generateId(_tableDischargeLiability);
}

// ------------------------------------------------------------------------------------------------------------------------
// inserts
Future<int> insertAccount(Account acc) {
  return db._insert(_tableAccounts, item: _accountToMap(acc));
}

Future<int> insertAccounts(List<Account> accounts) {
  return db._insert(_tableAccounts,
      items: accounts.map((f) {
        _accountToMap(f);
      }).toList());
}

Future<int> insertTransaction(AppTransaction transaction) {
  return db._insert(_tableTransactions, item: _transactionToMap(transaction));
}

Future<int> insertTransactions(List<AppTransaction> transactions) {
  return db._insert(_tableTransactions,
      items: transactions.map((f) {
        _transactionToMap(f);
      }).toList());
}

Future<int> insertCagetory(AppCategory cat) {
  return db._insert(_tableCategory, item: _categoryToMap(cat));
}

Future<int> insertCategories(List<AppCategory> cats) {
  return db._insert(_tableCategory, items: cats.map((f) => _categoryToMap(f)).toList());
}

Future<int> insertUser(User user) {
  return db._insert(tableUser, item: _userToMap(user));
}

Future<int> insertUsers(List<User> users) {
  return db._insert(tableUser, items: users.map((f) => _userToMap(f)).toList());
}

Future<int> insertBudget(Budget budget) {
  return db._insert(tableBudget, item: _budgetToMap(budget));
}

Future<int> insertBudgets(List<Budget> budgets) {
  return db._insert(tableBudget, items: budgets.map((f) => _budgetToMap(f)).toList());
}

Future<int> insertTransfer(Transfer transfer) {
  return db._insert(tableTransfer, item: _transferToMap(transfer));
}

Future<int> insertTransfers(List<Transfer> transfers) {
  return db._insert(tableTransfer, items: transfers.map((f) => _transferToMap(f)).toList());
}

Future<int> insertDischargeOfLiability(DischargeOfLiability discharge) {
  return db._insert(tableDischargeLiability, item: _dischargeLiabilityToMap(discharge));
}

Future<int> insertDischargeOfLiabilities(List<DischargeOfLiability> discharges) {
  return db._insert(tableDischargeLiability, items: discharges.map((f) => _dischargeLiabilityToMap(f)).toList());
}
// ------------------------------------------------------------------------------------------------------------------------
// delete
Future<int> deleteAccount(int id) {
  return db._delete(_tableAccounts, "$_id = ?", [id]);
}

Future<int> deleteAccounts(List<int> ids) {
  return db._delete(_tableAccounts, "$_id = ?", ids);
}

Future<int> deleteTransaction(int id) {
  return db._delete(_tableTransactions, "$_id = ?", [id]);
}

Future<int> deleteTransactions(List<int> ids) {
  return db._delete(_tableTransactions, "$_id = ?", ids);
}

Future<int> deleteCategory(int id) {
  return db._delete(_tableCategory, "$_id = ?", [id]);
}

Future<int> deleteCategories(List<int> ids) {
  return db._delete(_tableCategory, "$_id = ?", ids);
}

Future<int> deleteUser(String uid) {
  return db._delete(tableUser, "$_id = ?", [uid]);
}

Future<int> deleteUsers(List<String> uids) {
  return db._delete(tableUser, "$_id = ?", uids);
}

Future<int> deleteBudget(int id) {
  return db._delete(tableBudget, "$_id = ?", [id]);
}

Future<int> deleteBudgets(List<int> ids) {
  return db._delete(tableBudget, "$_id = ?", ids);
}

Future<int> deleteTransfer(int id) {
  return db._delete(tableTransfer, "$_id = ?", [id]);
}

Future<int> deleteTransfers(List<int> ids) {
  return db._delete(tableTransfer, "$_id = ?", ids);
}

Future<int> deleteDischargeOfLiability(int id) {
  return db._delete(tableDischargeLiability, "$_id = ?", [id]);
}

Future<int> deleteDischargeOfLiabilities(List<int> ids) {
  return db._delete(tableDischargeLiability, "$_id = ?", ids);
}

Future<void> dropAllTables() {
  return db._deleteDb();
}

Future<void> deleteTable(String table) {
  return db.deleteTable(table);
}

// ------------------------------------------------------------------------------------------------------------------------
// update
Future<int> updateAccount(Account acc) {
  return db._update(_tableAccounts, _accountToMap(acc), "$_id = ?", [acc.id]);
}

Future<int> updateTransaction(AppTransaction transaction) {
  return db._update(_tableTransactions, _transactionToMap(transaction), "$_id = ?", [transaction.id]);
}

Future<int> updateCategory(AppCategory cat) {
  // search for category's parent
  return db._update(_tableCategory, _categoryToMap(cat), "$_id = ?", [cat.id]);
}

Future<int> updateUser(User user) {
  return db._update(tableUser, _userToMap(user), "$_id = ?", [user.uuid]);
}

Future<int> updateBudget(Budget budget) {
  return db._update(tableBudget, _budgetToMap(budget), "$_id = ?", [budget.id]);
}

Future<int> updateTransfer(Transfer transfer) {
  return db._update(tableTransfer, _transferToMap(transfer), "$_id = ?", [transfer.id]);
}

Future<int> updateDischargeOfLiability(DischargeOfLiability discharge) {
  return db._update(tableDischargeLiability, _dischargeLiabilityToMap(discharge), "$_id = ?", [discharge.id]);
}

// ################################################################################################################
// private helper
// ################################################################################################################
AppTransaction _toTransaction(Map<String, dynamic> map) {
  return AppTransaction(map[_id], DateTime.fromMillisecondsSinceEpoch(map[_transDateTime]), map[_transAcc], map[_transCategory], (map[_transAmount] == null ? 0 : map[_transAmount]) * 1.0, map[_transDesc], map[_transType] == null ? null : TransactionType.all[map[_transType]], map[_transUid]);
}

Account _toAccount(Map<String, dynamic> map) {
  Account acc = new Account(map[_id], map[_accName], (map[_accInitialBalance] == null ? 0 : map[_accInitialBalance]) * 1.0, map[_accType] == null ? null : AccountType.all[map[_accType]], map[_accCurrency], created: map[_accCreated] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[_accCreated]));

  if(map[_accBalance] != null) acc.balance = map[_accBalance];
  if(map[_accSpent] != null) acc.spent = map[_accSpent];
  if(map[_accEarned] != null) acc.earn = map[_accEarned];

  return acc;
}

AppCategory _toCategory(Map<String, dynamic> map) {
  return AppCategory(
    map[_id],
    map[_catName],
    map[_catColorHex],
    CategoryType.all[map[_catCategoryType] == null ? 0 : map[_catCategoryType]]
  );
}

Budget _toBudget(Map<String, dynamic> map) {
  return Budget(
      map[_id],
      map[_budgetCategoryId],
      map[_budgetPerMonth] != null ? map[_budgetPerMonth] * 1.0 : 0.0,
      DateTime.fromMillisecondsSinceEpoch(map[_budgetStart]),
      map[_budgetEnd] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[_budgetEnd]),
      );
}

User _toUser(Map<String, dynamic> map) {
  return User(
    map[_id],
    map[_userEmail],
    map[_userDisplayName],
    map[_userPhotoUrl],
    map[_userColor],
    map[_userVerified]
  );
}

Transfer _toTransfer(Map<String, dynamic> map) {
  return Transfer(
    map[_id],
    map[_transferFrom],
    map[_transferTo],
    map[_transferAmount],
    map[_transferDate] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(map[_transferDate]),
    map[_transferUuid]
  );
}

DischargeOfLiability _toDischargeOfLiability(Map<String, dynamic> map) {
  return DischargeOfLiability(
    map[_id],
    map[_dischargeDateTime] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(map[_dischargeDateTime]),
    map[_dischargeLiabilityId],
    map[_dischargeFromAcc],
    map[_dischargeCategory],
    map[_dischargeAmount],
    map[_dischargeUid]
  );
}
Map<String, dynamic> _transactionToMap(AppTransaction transaction) {
  if(transaction.id == null) return null;

  var map = <String, dynamic>{};

  if(transaction.dateTime != null) map.putIfAbsent(_transDateTime, () => transaction.dateTime.millisecondsSinceEpoch);
  if(transaction.accountId != null) map.putIfAbsent(_transAcc, () => transaction.accountId);
  if(transaction.categoryId != null) map.putIfAbsent(_transCategory, () => transaction.categoryId);
  if(transaction.amount != null) map.putIfAbsent(_transAmount, () => transaction.amount);
  if(transaction.desc != null) map.putIfAbsent(_transDesc, () => transaction.desc);
  if(transaction.type != null) map.putIfAbsent(_transType, () => transaction.type.id);
  if(transaction.userUid != null) map.putIfAbsent(_transUid, () => transaction.userUid);

  map.putIfAbsent(_id, () => transaction.id);

  return map;
}

Map<String, dynamic> _accountToMap(Account acc) {
  if(acc.id == null) return null;

  var map = <String, dynamic>{};

  if(acc.name != null) map.putIfAbsent(_accName, () => acc.name);
  if(acc.initialBalance != null) map.putIfAbsent(_accInitialBalance, () => acc.initialBalance);
  if(acc.created != null) map.putIfAbsent(_accCreated, () => acc.created.millisecondsSinceEpoch);
  if(acc.type != null) map.putIfAbsent(_accType, () => acc.type.id);
  if(acc.currency != null) map.putIfAbsent(_accCurrency, () => acc.currency);

  map.putIfAbsent(_id, () => acc.id);

  return map;
}

Map<String, dynamic> _categoryToMap(AppCategory cat) {
  if(cat.id == null) return null;

  var map = <String, dynamic>{};

  if(cat.name != null) map.putIfAbsent(_catName, () => cat.name);
  if(cat.colorHex != null) map.putIfAbsent(_catColorHex, () => cat.colorHex);
  if(cat.categoryType != null) map.putIfAbsent(_catCategoryType, () => cat.categoryType.id);

  map.putIfAbsent(_id, () => cat.id);

  return map;
}

Map<String, dynamic> _budgetToMap(Budget budget) {
  if(budget.id == null) return null;

  var map = <String, dynamic>{};

  if(budget.categoryId != null) map.putIfAbsent(_budgetCategoryId, () => budget.categoryId);
  if(budget.budgetPerMonth != null) map.putIfAbsent(_budgetPerMonth, () => budget.budgetPerMonth);
  if(budget.budgetStart != null) map.putIfAbsent(_budgetStart, () => budget.budgetStart.millisecondsSinceEpoch);
  if(budget.budgetEnd != null) map.putIfAbsent(_budgetEnd, () => budget.budgetEnd.millisecondsSinceEpoch);

  map.putIfAbsent(_id, () => budget.id);

  return map;
}

Map<String, dynamic> _userToMap(User user) {
  if(user.uuid == null) return null;

  var map = <String, dynamic>{};

  if(user.email != null) map.putIfAbsent(_userEmail, () => user.email);
  if(user.displayName != null) map.putIfAbsent(_userDisplayName, () => user.displayName);
  if(user.photoUrl != null) map.putIfAbsent(_userPhotoUrl, () => user.photoUrl);
  if(user.color != null) map.putIfAbsent(_userColor, () => user.color);

  map.putIfAbsent(_id, () => user.uuid);

  return map;
}

Map<String, dynamic> _transferToMap(Transfer transfer) {
  if(transfer.id == null) return null;

   var map = <String, dynamic> {};

   if(transfer.transferDate != null) map.putIfAbsent(_transferDate, () => transfer.transferDate.millisecondsSinceEpoch);
   if(transfer.amount != null) map.putIfAbsent(_transferAmount, () => transfer.amount);
   if(transfer.fromAccount != null) map.putIfAbsent(_transferFrom, () => transfer.fromAccount);
   if(transfer.toAccount != null) map.putIfAbsent(_transferTo, () => transfer.toAccount);
   if(transfer.userUuid != null) map.putIfAbsent(_transferUuid, () => transfer.userUuid);

   map.putIfAbsent(_id, () => transfer.id);

   return map;
}

Map<String, dynamic> _dischargeLiabilityToMap(DischargeOfLiability discharge) {
  if(discharge.id == null) return null;

  var map = <String, dynamic>{};

  if(discharge.liabilityId != null) map.putIfAbsent(_dischargeLiabilityId, () => discharge.liabilityId);
  if(discharge.dateTime != null) map.putIfAbsent(_dischargeDateTime, () => discharge.dateTime.millisecondsSinceEpoch);
  if(discharge.accountId != null) map.putIfAbsent(_dischargeFromAcc, () => discharge.accountId);
  if(discharge.categoryId != null) map.putIfAbsent(_dischargeCategory, () => discharge.categoryId);
  if(discharge.amount != null) map.putIfAbsent(_dischargeAmount, () => discharge.amount);
  if(discharge.userUid != null) map.putIfAbsent(_dischargeUid, () => discharge.userUid);

  map.putIfAbsent(_id, () => discharge.id);

  return map;
}
String _compileFindBudgetSqlQuery(int monthStart, int monthEnd) {
  String findBudget = "";

  if(monthEnd == null) {
    findBudget = "$_budgetStart <= $monthStart";
  } else {
    // case 1
    // start to end   -----------|duration is around here|----------
    // budget -----------------------| budget is here until forever
    // include the case when budget starts before this period
    // budget --------------| budget is here until forever
    findBudget = "($_budgetEnd IS NULL AND $_budgetStart < $monthEnd)";
    // case 2
    // start to end   -----------|duration is around here|----------
    // budget -----------------------| budget is here |-------------
    findBudget += " OR ($_budgetStart >= $monthStart AND $_budgetEnd <= $monthEnd)";
    // case 3
    // start to end   -----------|duration is around here|----------
    // budget ---------------| budget is here until after end|----------
    // OR
    // budget ---------------| budget is here|----------
    findBudget += " OR ($_budgetStart <= $monthStart AND $_budgetEnd >= $monthStart)";

    // add bracelet
    findBudget = "($findBudget)";
  }

  return findBudget;
}

// #############################################################################################################################
// private database handler
// #############################################################################################################################
class _Database {
  Database db;
  Map<String, List<DatabaseObservable>> _watchers = {};
  _PrivateDbHelper _privateDbHelper = _PrivateDbHelper();

  Future<Database> _openDatabase() async {
    String dbPath = join((await getApplicationDocumentsDirectory()).path, "MyWalletDb");
    return await openDatabase(
        dbPath,
        version: 11, onCreate: (Database db, int version) async {
      await _privateDbHelper._executeCreateDatabase(db);
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // on upgrade? delete all tables and create all new
      var allTables = [
        _tableTransactions,
        _tableBudget,
        _tableCategory,
        _tableUser,
        _tableAccounts,
        _tableTransfer,
        _tableDischargeLiability
      ];

      for(String tbl in allTables) {
        try {
          await db.execute("DROP TABLE $tbl");
        } catch(e, stacktrace) {
          print(stacktrace);
        }
      }

      await _privateDbHelper._executeCreateDatabase(db);
    });
  }

  Future<void> init() async {
    db = await _openDatabase();
  }

  Future<void> dispose() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(prefPausedTime, DateTime.now().millisecondsSinceEpoch);

    await db.close();
  }

  Future<int> _generateId(String table) async {
      if(!db.isOpen) db = await _openDatabase();
      int id = 0;

      var ids = await db.rawQuery("SELECT MAX($_id) FROM $table");

      if(ids.length >= 0) {
        id = ids[0].values.first;
      }

      return id == null ? 0 : id + 1;
  }

  Future<List<Map<String, dynamic>>> _executeSql(String sql) async {
      if(!db.isOpen) db = await _openDatabase();

      var result = await db.rawQuery(sql);

      return result;
  }

  Future<List<Map<String, dynamic>>> _query(String table, {String where, List whereArgs, String orderBy, List<String> columns}) async {
      if(!db.isOpen) db = await _openDatabase();

      List<Map<String, dynamic>> map = await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, columns: columns);

      return map;
  }

  Future<int> _insert(String table, {Map<String, dynamic> item, List<Map<String, dynamic>> items}) async {
      if(!db.isOpen) db = await _openDatabase();
      var result = -1;

      if (item != null) {
        item.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);
        if (item[_id] == null) {
          var id = await _generateId(table);
          item.putIfAbsent(_id, () => id);
        }

        result = await db.insert(table, item);

        if(result >= 0) {
          if (table == _tableTransactions) {
            // recalculate account balance for transaction
            await _privateDbHelper._recalculateAccountForTransaction(db, item);
          }

          if (table == _tableAccounts) {
            await _privateDbHelper._recalculateAccount(db, item[_id]);
          }

          if(table == _tableTransfer) {
              await _privateDbHelper._recalculateAccount(db, item[_transferFrom]);
              await _privateDbHelper._recalculateAccount(db, item[_transferTo]);
          }

          if(table == _tableDischargeLiability) {
              await _privateDbHelper._recalculateAccount(db, item[_dischargeFromAcc]);
              await _privateDbHelper._recalculateAccount(db, item[_dischargeLiabilityId]);
          }
        }
      }

      if (items != null) {
        for (item in items) {
          item.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);
          if (item[_id] == null) {
            var id = await _generateId(table);
            item.putIfAbsent(_id, () => id);
          }

          var singleResult = await db.insert(table, item);

          if (result < 0)
            result = singleResult;
          else
            result += singleResult;

          if(singleResult >= 0) {
            if (table == _tableTransactions) {
              // recalculate account balance for transaction
              await _privateDbHelper._recalculateAccountForTransaction(db, item);
            }

            if(table == _tableAccounts) {
              await _privateDbHelper._recalculateAccount(db, item[_id]);
            }

            if(table == _tableTransfer) {
                await _privateDbHelper._recalculateAccount(db, item[_transferFrom]);
                await _privateDbHelper._recalculateAccount(db, item[_transferTo]);
            }

            if(table == _tableDischargeLiability) {
              await _privateDbHelper._recalculateAccount(db, item[_dischargeFromAcc]);
              await _privateDbHelper._recalculateAccount(db, item[_dischargeLiabilityId]);
            }
          }
        }
      }

    if(result > 0) _notifyObservers(table);

    return result;
  }

  Future<int> _delete(String table, String where, List whereArgs) async {
      if(!db.isOpen) db = await _openDatabase();

      var result = await db.delete(table, where: where, whereArgs: whereArgs);

      if(table == _tableTransactions || table == _tableTransfer || table == _tableDischargeLiability) {
        // recalculate account table
        await _privateDbHelper._recalculateAllAccounts(db);
      }

    if(result > 0) _notifyObservers(table);

    return result;
  }

  Future<int> _update(String table, Map<String, dynamic> item, String where, List whereArgs) async {
      if(!db.isOpen) db = await _openDatabase();

      item.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);
      var result = await db.update(table, item, where: where, whereArgs: whereArgs);

      if (table == _tableTransactions) {
        var transactions = await db.query(_tableTransactions, where: where, whereArgs: whereArgs);

        for(Map<String, dynamic> transaction in transactions) {
          // recalculate account balance for transaction
          await _privateDbHelper._recalculateAccountForTransaction(db, transaction);
        }
      }

      if (table == _tableAccounts) {
        var accounts = await db.query(_tableAccounts, where: where, whereArgs: whereArgs, columns: [_id]);

        for(Map<String, dynamic> account in accounts) {
          await _privateDbHelper._recalculateAccount(db, account[_id]);
        }
      }

      if(table == _tableTransfer) {
        var transfers = await db.query(_tableTransfer, where: where, whereArgs: whereArgs);

        for(Map<String, dynamic> transfer in transfers) {
            await _privateDbHelper._recalculateAccount(db, transfer[_transferFrom]);
            await _privateDbHelper._recalculateAccount(db, transfer[_transferTo]);
        }
      }

      if(table == _tableDischargeLiability) {
        await _privateDbHelper._recalculateAccount(db, item[_dischargeFromAcc]);
        await _privateDbHelper._recalculateAccount(db, item[_dischargeLiabilityId]);
      }

    if(result > 0) _notifyObservers(table);

    return result;
  }

  Future<void> _deleteDb() async {
      if(!db.isOpen) db = await _openDatabase();

      String path = db.path;

      await db.close();
      await deleteDatabase(path);
  }

  Future<void> deleteTable(String name) async {
      if(!db.isOpen) db = await _openDatabase();
      await db.delete(name);
  }

  void _notifyObservers(String table) {
    if(_watchers[table] != null) _watchers[table].forEach((f) => f.onDatabaseUpdate(table));
  }

  void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
    if (tables != null) {
    tables.forEach((f) {
      List<DatabaseObservable> list = _watchers[f];

      if(list == null) list = [];

      list.add(observable);

      _watchers.remove(f);
      _watchers.putIfAbsent(f, () => list);
    });
    }
  }

  void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
    if(tables != null) {
      tables.forEach((f) {
        List<DatabaseObservable> list = _watchers[f];

        if(list != null) list.remove(observable);

        _watchers.remove(f);
        _watchers.putIfAbsent(f, () => list);
      });
    }
  }
}

class _PrivateDbHelper {
  Future<void> _executeCreateDatabase(Database db) async {
    await db.execute("""
            CREATE TABLE $_tableAccounts (
              $_id INTEGER PRIMARY KEY,
              $_accName TEXT NOT NULL,
              $_accInitialBalance DOUBLE NOT NULL,
              $_accCreated INTEGER NOT NULL,
              $_accType INTEGER NOT NULL,
              $_accCurrency TEXT NOT NULL,
              $_accBalance DOUBLE,
              $_accSpent DOUBLE,
              $_accEarned DOUBLE,
              $_updated INTEGER NOT NULL
            )""");

    await db.execute("""
          CREATE TABLE $_tableTransactions (
          $_id INTEGER PRIMARY KEY,
          $_transDateTime LONG NOT NULL,
          $_transAcc INTEGER NOT NULL,
          $_transCategory INTEGER NOT NULL,
          $_transAmount DOUBLE NOT NULL,
          $_transDesc TEXT,
          $_transType INTEGER NOT NULL,
          $_transUid TEXT NOT NULL,
          $_updated INTEGER NOT NULL
          )""");

    await db.execute("""
        CREATE TABLE $_tableCategory (
        $_id INTEGER PRIMARY KEY,
        $_catName TEXT NOT NULL,
        $_catColorHex TEXT NOT NULL,
        $_catCategoryType INTEGER NOT NULL,
        $_updated INTEGER NOT NULL
        )
        """);

    await db.execute("""
        CREATE TABLE $_tableBudget (
        $_id INTEGER PRIMARY KEY,
        $_budgetCategoryId INTEGER NOT NULL,
        $_budgetPerMonth DOUBLE NOT NULL,
        $_budgetStart INTEGER NOT NULL,
        $_budgetEnd INTEGER,
        $_updated INTEGER NOT NULL
        )
        """);

    await db.execute("""
        CREATE TABLE $_tableUser (
        $_id TEXT NOT NULL PRIMARY KEY,
        $_userDisplayName TEXT NOT NULL,
        $_userEmail TEXT NOT NULL,
        $_userPhotoUrl TEXT,
        $_userColor INTEGER,
        $_updated INTEGER NOT NULL
      )
      """);

    await db.execute("""
        CREATE TABLE $_tableTransfer (
        $_id INTEGER PRIMARY KEY,
        $_transferFrom INTEGER NOT NULL,
        $_transferTo INTEGER NOT NULL,
        $_transferAmount DOUBLE NOT NULL,
        $_transferDate INTEGER NOT NULL,
        $_transferUuid TEXT NOT NULL,
        $_updated INTEGER NOT NULL
        )
        """);

    await db.execute("""
      CREATE TABLE $_tableDischargeLiability (
      $_id INTEGER PRIMARY KEY,
      $_dischargeLiabilityId INTEGER NOT NULL,
      $_dischargeFromAcc INTEGER NOT NULL,
      $_dischargeAmount DOUBLE NOT NULL,
      $_dischargeDateTime INTEGER NOT NULL,
      $_dischargeCategory INTEGER NOT NULL,
      $_dischargeUid TEXT NOT NULL,
      $_updated INTEGER NOT NULL
      )
    """);
  }

  Future<void> _recalculateAllAccounts(Database db) async {
    var accounts = await db.rawQuery("SELECT $_id FROM $_tableAccounts");

    for(Map<String, dynamic> account in accounts) {
      await _recalculateAccount(db, account.values.first);
    }
  }

  Future<void> _recalculateAccountForTransaction(Database db, Map<String, dynamic> tran) async {
    do {
      if(tran == null) break;
      if(tran.isEmpty) break;

      var transactionId = tran[_id];

      if(transactionId == null) break;

      var accountId = tran[_transAcc];
      if(accountId == null) {
        // query from database
        accountId = await db.rawQuery("SELECT $_transAcc from $_tableTransactions WHERE $_id = $transactionId");
      }

      await _recalculateAccount(db, accountId);
    } while(false);
  }

  Future<void> _recalculateAccount(Database db, int accountId) async {
    var initialBalance = 0.0;
    var rawInitialBalance = await db.rawQuery("SELECT $_accInitialBalance FROM $_tableAccounts WHERE $_id = $accountId");
    if(rawInitialBalance != null
        && rawInitialBalance.isNotEmpty
        && rawInitialBalance.first != null
        && rawInitialBalance.first.values != null
        && rawInitialBalance.first.values.isNotEmpty
        && rawInitialBalance.first.values.first != null) initialBalance = rawInitialBalance.first.values.first;

    // ########################################################################
    // calculate all money out
    String type = TransactionType.typeExpense.map((f) => "${f.id}").toString();
    var spent = 0.0;

    // expenses
    var expenses = (await db.rawQuery("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE $_transAcc = $accountId AND $_transType in $type")).first.values.first ?? 0.0;
    spent += expenses;

    // transfer out
    var transferOut = (await db.rawQuery("SELECT SUM($_transferAmount) FROM $_tableTransfer WHERE $_transferFrom = $accountId")).first.values.first ?? 0.0;
    spent += transferOut;

    // pay liability
    var payLiability = (await db.rawQuery("SELECT SUM($_dischargeAmount) FROM $_tableDischargeLiability WHERE $_dischargeFromAcc = $accountId")).first.values.first ?? 0.0;
    spent += payLiability;

    // ########################################################################
    // calculate money in
    type = TransactionType.typeIncome.map((f) => "${f.id}").toString();
    var earn = 0.0;

    // income
    var income = (await db.rawQuery("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE $_transAcc = $accountId AND $_transType in $type")).first.values.first ?? 0.0;
    earn += income;

    // transfer in
    var transferIn = (await db.rawQuery("SELECT SUM($_transferAmount) FROM $_tableTransfer WHERE $_transferTo = $accountId")).first.values.first ?? 0.0;
    earn += transferIn;

    // discharge of liability
    var dischargeLiability = (await db.rawQuery("SELECT SUM($_dischargeAmount) FROM $_tableDischargeLiability WHERE $_dischargeLiabilityId = $accountId")).first.values.first ?? 0.0;

    var balance = initialBalance + earn - spent - dischargeLiability;

    await db.update(_tableAccounts, {
      _accBalance: balance,
      _accSpent: spent,
      _accEarned: earn
    }, where: "$_id = ?", whereArgs: [accountId]);
  }
}


