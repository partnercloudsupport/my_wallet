import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_wallet/data/data.dart';
import 'package:synchronized/synchronized.dart';
import 'package:my_wallet/data/data_observer.dart';
import 'package:my_wallet/utils.dart' as Utils;

import 'package:flutter/foundation.dart';

// #############################################################################################################################
// database manager
// #############################################################################################################################
final _id = "_id";

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

// table budget
final _tableBudget = tableBudget;
final _budgetCategoryId = "_catId";
final _budgetPerMonth = "_budgetPerMonth";
final _budgetStart = "_budgetStart";
final _budgetEnd = "_budgetEnd";
final _budgetSpent = "_budgetSpent";
final _budgetEarn = "_budgetEarn";

final _tableUser = tableUser;
final _userDisplayName = "_displayName";
final _userEmail = "_email";
final _userPhotoUrl = "_photoUrl";
final _userColor = "_userColor";

_Database db = _Database();
Lock _lock = Lock();

void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  _lock.synchronized(() => db.registerDatabaseObservable(tables, observable));
}

void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  _lock.synchronized(() => db.unregisterDatabaseObservable(tables, observable));
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

// ------------------------------------------------------------------------------------------------------------------------
// other SQL helper methods
Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type) async {
  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}) AND $_transType IN ${type.map((f) => "${f.id}").toString()}"));

  return sum[0].values.first ?? 0.0;
}

Future<double> sumAllAccountBalance({List<AccountType> types}) async {
  var where = "";

  if (types != null && types.isNotEmpty) {
    var typeWhere = types.map((f) => "${f.id}").toString();

    where = " WHERE $_accType in $typeWhere";
  }

  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_accBalance) FROM $_tableAccounts$where"));

  return sum[0].values.first ?? 0.0;
}

Future<double> sumTransactionsByDay(DateTime day, TransactionType type) async {
    var startOfDay = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    var endOfDay = DateTime(day.year, day.month, day.day + 1).millisecondsSinceEpoch;

    var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN $startOfDay AND $endOfDay) AND $_transType = ${type.id}"));

    return sum[0].values.first ?? 0.0;
}

Future<double> sumTransactionsByCategory({@required int catId, @required List<TransactionType> type, @required DateTime start, @required DateTime end}) async {
  String types = type.map((f) => "${f.id}").toString();
  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}) AND $_transCategory = $catId AND $_transType in $types"));

  return sum[0].values.first ?? 0.0;
}

Future<double> sumAllBudget(DateTime start, DateTime end) async {
  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_budgetPerMonth) FROM $_tableBudget WHERE ($_budgetStart >= ${start.millisecondsSinceEpoch} and $_budgetEnd <= ${end.millisecondsSinceEpoch})"));
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

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableAccounts, where: where, whereArgs: whereArgs));

  if (map != null) {
    return map.map((f) => _toAccount(f)).toList();
  }

  return null;
}

Future<List<AppTransaction>> queryTransactions({int id}) async {
  String where;

  if(id != null) where = "$_id = $id";

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: where));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionsBetweenDates(DateTime from, DateTime to, {TransactionType type}) async {
  String where = from != null && to != null ? "$_transDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}" : null;

  if(type != null) {
    where = "($where) AND $_transType = ${type.id}";
  }

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: where));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForCategory(int categoryId, DateTime day) async {
  var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
  var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transCategory = $categoryId AND ($_transDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})"));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryAllTransactionForCategory(int categoryId) async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transCategory = $categoryId"));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForAccount(int accountId, DateTime day) async {
  var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
  var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transAcc = $accountId AND ($_transDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})"));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryAllTransactionForAccount(int accountId) async {

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transAcc = $accountId"));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<DateTime>> findTransactionsDates(DateTime day, {int accountId, int categoryId}) async {
  Map<DateTime, DateTime> dates = {};
  String where;

  DateTime start = Utils.firstMomentOfMonth(day == null ? DateTime.now() : day);
  DateTime end = Utils.lastDayOfMonth(day == null ? DateTime.now() : day);

  String dateWhere = "$_transDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}";

  if(accountId != null) where = "$_transAcc = $accountId";
  if(categoryId != null) where = "${where != null ? "$where AND " : ""}$_transCategory = $categoryId";

  where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: where));

  if(map != null && map.isNotEmpty) {
    for(int i = 0; i < map.length; i++) {
      if(map[i][_transDateTime] != null) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(map[i][_transDateTime]));

        dates.putIfAbsent(date, () => date);
      }
    }
  }

  return dates.keys.toList();
}

Future<List<AppCategory>> queryCategory({int id}) async {
  String where;
  List<int> whereArg;

  if (id == null) {
    where = null;
    whereArg = null;
  } else {
    where = "$_id = ?";
    whereArg = [id];
  }
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableCategory, where: where, whereArgs: whereArg));

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

  List<Map<String, dynamic>> catMaps = await _lock.synchronized(() => db._query(_tableCategory));

  List<Map<String, dynamic>> transMap = await _lock.synchronized(() => db._query(
      _tableTransactions,
      where: where));

  List<AppTransaction> trans = transMap == null ? [] : transMap.map((f) => _toTransaction(f)).toList();

  List<AppCategory> appCats = [];

  appCats = catMaps == null
      ? []
      : catMaps.map((f) {
          var income = 0.0;
          var expense = 0.0;
          var catId = f[_id];
          trans.forEach((trans) {
            income += trans.categoryId == catId && TransactionType.isIncome(trans.type) ? trans.amount : 0.0;
            expense += trans.categoryId == catId && TransactionType.isExpense(trans.type)? trans.amount : 0.0;
          });

          return AppCategory(
            f[_id],
            f[_catName],
            f[_catColorHex],
            income,
            expense
          );
        }).toList();

  if (filterZero) appCats.removeWhere((f) => f.income == 0 && f.expense == 0);

  if(orderByType && type != null) {
    if(type == TransactionType.typeExpense) {
      // sort by expenses
      appCats.sort((a, b) => b.expense.floor() - a.expense.floor());
    } else if(type == TransactionType.typeIncome) {
      // sort by income
      appCats.sort((a, b) => b.income.floor() - a.income.floor());
    }
  }
  return appCats;
}

Future<List<AppTransaction>> queryForDate(DateTime day) async {
  DateTime startOfDay = DateTime(day.year, day.month, day.day, 0, 0);

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transDateTime BETWEEN ? AND ?", whereArgs: [startOfDay.millisecondsSinceEpoch, startOfDay.add(Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999)).millisecondsSinceEpoch]));

  return map != null ? map.map((f) => _toTransaction(f)).toList() : null;
}

Future<List<User>> queryUser({String uuid}) async {
  String where;
  List whereArgs;

  if(uuid != null) {
    where = "$_id = ?";
    whereArgs = [uuid];
  }
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableUser, where: where, whereArgs: whereArgs));

  return map == null ? null : map.map((f) => _toUser(f)).toList();
}

Future<List<Budget>> queryBudgets() async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableBudget));

  return map == null ? null : map.map((f) => _toBudget(f)).toList();
}

Future<DateTime> queryMinBudgetStart() async {
  var min = await _lock.synchronized(() => db._executeSql("SELECT MIN($_budgetStart) FROM $_tableBudget"));

  return min == null || min[0].values == null || min[0].values.first == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(min[0].values.first);
}

Future<DateTime> queryMaxBudgetEnd() async {
  var max = await _lock.synchronized(() => db._executeSql("SELECT MAX($_budgetEnd) FROM $_tableBudget"));

  return max == null || max[0].values == null || max[0].values.first == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(max[0].values.first);
}

Future<Budget> queryBudgetAmount({int catId, @required DateTime start, @required DateTime end}) async {
  var monthStart = Utils.firstMomentOfMonth(start);
  var monthEnd = Utils.lastDayOfMonth(end);

  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_budgetPerMonth) FROM $_tableBudget WHERE ${catId == null ? "" : "$_budgetCategoryId = $catId AND "}$_budgetStart <= ${monthStart.millisecondsSinceEpoch} AND $_budgetEnd >= ${monthEnd.millisecondsSinceEpoch}"));

  var amount = sum == null || sum.isEmpty ? 0.0 : sum[0].values.first ?? 0.0;
  return Budget(0, catId, amount, monthStart, monthEnd);
}

Future<Budget> findBudget(int catId, DateTime start, DateTime end) async {
  var monthStart = Utils.firstMomentOfMonth(start);
  var monthEnd = Utils.lastDayOfMonth(end);

  var listMap = await _lock.synchronized(() => db._query(_tableBudget, where: "$_budgetCategoryId = $catId AND $_budgetStart = ${monthStart.millisecondsSinceEpoch} AND $_budgetEnd = ${monthEnd.millisecondsSinceEpoch}"));

  return listMap == null || listMap.isEmpty ? null : _toBudget(listMap[0]);
}

Future<List<Budget>> findAllBudgetForCategory(int catId) async {
  var listMap = await _lock.synchronized(() => db._query(_tableBudget, where: "$_budgetCategoryId = $catId"));

  return listMap == null || listMap.isEmpty ? null : listMap.map((f) => _toBudget(f)).toList();
}

Future<int> generateAccountId() {
  return _lock.synchronized(() => db._generateId(_tableAccounts));
}

Future<int> generateTransactionId() {
  return _lock.synchronized(() => db._generateId(_tableTransactions));
}

Future<int> generateCategoryId() {
  return _lock.synchronized(() => db._generateId(_tableCategory));
}

Future<int> generateBudgetId() {
  return _lock.synchronized(() => db._generateId(_tableBudget));
}

// ------------------------------------------------------------------------------------------------------------------------
// inserts
Future<int> insertAccount(Account acc) {
  return _lock.synchronized(() => db._insert(_tableAccounts, item: _accountToMap(acc)));
}

Future<int> insertAccounts(List<Account> accounts) {
  return _lock.synchronized(() => db._insert(_tableAccounts,
      items: accounts.map((f) {
        _accountToMap(f);
      }).toList()));
}

Future<int> insertTransaction(AppTransaction transaction) {
  return _lock.synchronized(() => db._insert(_tableTransactions, item: _transactionToMap(transaction)));
}

Future<int> insertTransactions(List<AppTransaction> transactions) {
  return _lock.synchronized(() => db._insert(_tableTransactions,
      items: transactions.map((f) {
        _transactionToMap(f);
      }).toList()));
}

Future<int> insertCagetory(AppCategory cat) {
  return _lock.synchronized(() => db._insert(_tableCategory, item: _categoryToMap(cat)));
}

Future<int> insertCategories(List<AppCategory> cats) {
  return _lock.synchronized(() => db._insert(_tableCategory, items: cats.map((f) => _categoryToMap(f)).toList()));
}

Future<int> insertUser(User user) {
  return _lock.synchronized(() => db._insert(tableUser, item: _userToMap(user)));
}

Future<int> insertUsers(List<User> users) {
  return _lock.synchronized(() => db._insert(tableUser, items: users.map((f) => _userToMap(f)).toList()));
}

Future<int> insertBudget(Budget budget) {
  return _lock.synchronized(() => db._insert(tableBudget, item: _budgetToMap(budget)));
}

Future<int> insertBudgets(List<Budget> budgets) {
  return _lock.synchronized(() => db._insert(tableBudget, items: budgets.map((f) => _budgetToMap(f)).toList()));
}

// ------------------------------------------------------------------------------------------------------------------------
// delete
Future<int> deleteAccount(int id) {
  return _lock.synchronized(() => db._delete(_tableAccounts, "$_id = ?", [id]));
}

Future<int> deleteAccounts(List<int> ids) {
  return _lock.synchronized(() => db._delete(_tableAccounts, "$_id = ?", ids));
}

Future<int> deleteTransaction(int id) {
  return _lock.synchronized(() => db._delete(_tableTransactions, "$_id = ?", [id]));
}

Future<int> deleteTransactions(List<int> ids) {
  return _lock.synchronized(() => db._delete(_tableTransactions, "$_id = ?", ids));
}

Future<int> deleteCategory(int id) {
  return _lock.synchronized(() => db._delete(_tableCategory, "$_id = ?", [id]));
}

Future<int> deleteCategories(List<int> ids) {
  return _lock.synchronized(() => db._delete(_tableCategory, "$_id = ?", ids));
}

Future<int> deleteUser(String uid) {
  return _lock.synchronized(() => db._delete(tableUser, "$_id = ?", [uid]));
}

Future<int> deleteUsers(List<String> uids) {
  return _lock.synchronized(() => db._delete(tableUser, "$_id = ?", uids));
}

Future<int> deleteBudget(int id) {
  return _lock.synchronized(() => db._delete(tableBudget, "$_id = ?", [id]));
}

Future<int> deleteBudgets(List<int> ids) {
  return _lock.synchronized(() => db._delete(tableBudget, "$_id = ?", ids));
}

Future<void> dropAllTables() {
  return _lock.synchronized(() => db._deleteDb());
}

Future<void> deleteTable(String table) {
  return _lock.synchronized(() => db.deleteTable(table));
}

// ------------------------------------------------------------------------------------------------------------------------
// update
Future<int> updateAccount(Account acc) {
  return _lock.synchronized(() => db._update(_tableAccounts, _accountToMap(acc), "$_id = ?", [acc.id]));
}

Future<int> updateTransaction(AppTransaction transaction) {
  return _lock.synchronized(() => db._update(_tableTransactions, _transactionToMap(transaction), "$_id = ?", [transaction.id]));
}

Future<int> updateCategory(AppCategory cat) {
  // search for category's parent
  return _lock.synchronized(() => db._update(_tableCategory, _categoryToMap(cat), "$_id = ?", [cat.id]));
}

Future<int> updateUser(User user) {
  return _lock.synchronized(() => db._update(tableUser, _userToMap(user), "$_id = ?", [user.uuid]));
}

Future<int> updateBudget(Budget budget) {
  return _lock.synchronized(() => db._update(tableBudget, _budgetToMap(budget), "$_id = ?", [budget.id]));
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
    0.0,
    0.0
  );
}

Budget _toBudget(Map<String, dynamic> map) {
  return Budget(
      map[_id],
      map[_budgetCategoryId],
      map[_budgetPerMonth] * 1.0,
      DateTime.fromMillisecondsSinceEpoch(map[_budgetStart]),
      DateTime.fromMillisecondsSinceEpoch(map[_budgetEnd]),
      spent: map[_budgetSpent],
      earn: map[_budgetEarn]);
}

User _toUser(Map<String, dynamic> map) {
  return User(
    map[_id],
    map[_userEmail],
    map[_userDisplayName],
    map[_userPhotoUrl],
    map[_userColor],
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
  if(budget.spent != null) map.putIfAbsent(_budgetSpent, () => budget.spent);
  if(budget.earn != null) map.putIfAbsent(_budgetEarn, () => budget.earn);

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


// #############################################################################################################################
// private database handler
// #############################################################################################################################
class _Database {
  Database db;
  Map<String, List<DatabaseObservable>> _watchers = {};

  Future<Database> _openDatabase() async {
    String dbPath = join((await getApplicationDocumentsDirectory()).path, "MyWalletDb");
    db = await openDatabase(
        dbPath,
        version: 4, onCreate: (Database db, int version) async {
      await _executeCreateDatabase(db);
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // on upgrade? delete all tables and create all new
      var allTables = [
        _tableTransactions,
        _tableBudget,
        _tableCategory,
        _tableUser,
        _tableAccounts
      ];

      for(String tbl in allTables) {
        await db.execute("DROP TABLE $tbl");
      }

      await _executeCreateDatabase(db);
    });

    return db;
  }

  Future<void> init() async {
    db = await _openDatabase();
  }

  Future<void> dispose() async {
    await db.close();
  }
  
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
              $_accEarned DOUBLE
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
          $_transUid TEXT NOT NULL
          )""");

    await db.execute("""
        CREATE TABLE $_tableCategory (
        $_id INTEGER PRIMARY KEY,
        $_catName TEXT NOT NULL,
        $_catColorHex TEXT NOT NULL
        )
        """);

    await db.execute("""
        CREATE TABLE $_tableBudget (
        $_id INTEGER PRIMARY KEY,
        $_budgetCategoryId INTEGER NOT NULL,
        $_budgetPerMonth DOUBLE NOT NULL,
        $_budgetStart INTEGER NOT NULL,
        $_budgetEnd INTEGER,
        $_budgetSpent DOUBLE,
        $_budgetEarn DOUBLE
        )
        """);

    await db.execute("""
        CREATE TABLE $_tableUser (
        $_id TEXT NOT NULL PRIMARY KEY,
        $_userDisplayName TEXT NOT NULL,
        $_userEmail TEXT NOT NULL,
        $_userPhotoUrl TEXT,
        $_userColor INTEGER
      )
      """);
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

  Future<List<Map<String, dynamic>>> _query(String table, {String where, List whereArgs, String orderBy}) async {
    if(!db.isOpen) db = await _openDatabase();

    List<Map<String, dynamic>> map = await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);

    return map;
  }

  Future<int> _insert(String table, {Map<String, dynamic> item, List<Map<String, dynamic>> items}) async {
    if(!db.isOpen) db = await _openDatabase();
    var result = -1;

    if (item != null) {
      if (item[_id] == null) {
        var id = await _generateId(table);
        item.putIfAbsent(_id, () => id);
      }

      result = await db.insert(table, item);

      if(result >= 0) {
        if (table == _tableBudget) {
          // recalculate budget
          await _recalculateBudget(db, item);
        }

        if (table == _tableTransactions) {
          // recalculate budget for transaction
          await _recalculateBudgetForTransaction(db, item);
          // recalculate account balance for transaction
          await _recalculateAccountForTransaction(db, item);
        }

        if (table == _tableAccounts) {
          await _recalculateAccount(db, item[_id]);
        }
      }
    }

    if (items != null) {
      for (item in items) {
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
          if (table == _tableBudget) {
            // recalculate budget
            await _recalculateBudget(db, item);
          }

          if (table == _tableTransactions) {
            // recalculate budget for transaction
            await _recalculateBudgetForTransaction(db, item);
            // recalculate account balance for transaction
            await _recalculateAccountForTransaction(db, item);
          }

          if(table == _tableAccounts) {
            await _recalculateAccount(db, item[_id]);
          }
        }
      }
    }

    _notifyObservers(table);

    return result;
  }

  Future<int> _delete(String table, String where, List whereArgs) async {
    if(!db.isOpen) db = await _openDatabase();
    var result = await db.delete(table, where: where, whereArgs: whereArgs);

    if(table == _tableBudget) {
      // recalculate budgets table
      _recalculateBudgets(db, whereArgs);
    }

    if(table == _tableTransactions) {
      // recalculate budget table
      _recalculateAllBudgets(db);
      // recalculate account table
      _recalculateAllAccounts(db);
    }

    _notifyObservers(table);

    return result;
  }

  Future<int> _update(String table, Map<String, dynamic> item, String where, List whereArgs) async {
    if(!db.isOpen) db = await _openDatabase();
    var result = await db.update(table, item, where: where, whereArgs: whereArgs);

    if (table == _tableBudget) {
      var budgets = await db.query(_tableBudget, where: where, whereArgs: whereArgs);

      for(Map<String, dynamic> budget in budgets) {
        // recalculate budget
        await _recalculateBudget(db, budget);
      }
    }

    if (table == _tableTransactions) {
      var transactions = await db.query(_tableTransactions, where: where, whereArgs: whereArgs);

      for(Map<String, dynamic> transaction in transactions) {
        // recalculate budget for transaction
        await _recalculateBudgetForTransaction(db, transaction);
        // recalculate account balance for transaction
        await _recalculateAccountForTransaction(db, transaction);
      }
    }

    if (table == _tableAccounts) {
      var accounts = await db.query(_tableAccounts, where: where, whereArgs: whereArgs, columns: [_id]);

      for(Map<String, dynamic> account in accounts) {
        await _recalculateAccount(db, account[_id]);
      }
    }

    _notifyObservers(table);

    return result;
  }

  Future<void> _deleteDb() async {
    if(!db.isOpen) db = await _openDatabase();

    String path = db.path;

    db.close();
    await deleteDatabase(path);
  }

  Future<void> deleteTable(String name) async {
    if(!db.isOpen) db = await _openDatabase();
    await db.delete(name);
  }

  void _notifyObservers(String table) async {
    if(_watchers[table] != null) _watchers[table].forEach((f) => f.onDatabaseUpdate(table));
  }

  Future<void> _recalculateBudgets(Database db, List<dynamic> ids) async {
    var budgets = await db.rawQuery("SELECT $_id, $_budgetCategoryId, $_budgetStart, $_budgetEnd, $_budgetPerMonth FROM $_tableBudget WHERE $_id IN ${ids.map((f) => "$f").toString()}");

    for(Map<String, dynamic> budget in budgets) {
      await _recalculateBudget(db, budget);
    }
  }

  Future<void> _recalculateBudget(Database db, Map<String, dynamic> budget) async {
    do {
      if(budget == null) break;
      if(budget.isEmpty) break;

      // get budget category ID out
      var catId = budget[_budgetCategoryId];
      // get startDate out
      var startDate = budget[_budgetStart];
      // and end date
      var endDate = budget[_budgetEnd];
      // get budget ID
      var id = budget[_id];
      // get budget per month
      var amount = budget[_budgetPerMonth];

      // query all transactions of type income for this category between this start and end date
      var typesList = TransactionType.typeExpense;
      String types = typesList.map((f) => "${f.id}").toString();
      var sql = "SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN $startDate AND $endDate) AND $_transCategory = $catId AND $_transType in $types";
      var sum = await db.rawQuery(sql);
      var spent = sum[0].values.first ?? 0.0;

      typesList = TransactionType.typeIncome;
      types = typesList.map((f) => "${f.id}").toString();
      sql = "SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN $startDate AND $endDate) AND $_transCategory = $catId AND $_transType in $types";
      sum = await db.rawQuery(sql);
      var earn = sum[0].values.first ?? 0.0;

      var newBudget = <String, dynamic>{
        _id: id,
        _budgetCategoryId: catId,
        _budgetStart: startDate,
        _budgetEnd: endDate,
        _budgetPerMonth: amount,
        _budgetSpent: spent,
        _budgetEarn: earn
      };

      // update this budget
      await db.update(_tableBudget, newBudget, where: "$_id = ?", whereArgs: [id]);
    } while(false);
  }

  Future<void> _recalculateAllBudgets(Database db) async {
    var budgets = await db.rawQuery("SELECT  $_id from $_tableBudget");

    for(dynamic budget in budgets) {
      await _recalculateBudget(db, budget);
    }
  }

  Future<void> _recalculateBudgetForTransaction(Database db, Map<String, dynamic> tran) async {
    do {

      if(tran == null) break;
      if(tran.isEmpty) break;

      // get full transaction info
      var transactionId = tran[_id];

      var listTransactions = await db.query(_tableTransactions,where: "$_id = ?", whereArgs: [transactionId]);

      if(listTransactions == null) break;
      if(listTransactions.isEmpty) break;

      var transaction = listTransactions[0];
      var catId = transaction[_transCategory];

      var transDate = transaction[_transDateTime];

      var startDate = Utils.firstMomentOfMonth(DateTime.fromMillisecondsSinceEpoch(transDate)).millisecondsSinceEpoch;
      var endDate = Utils.lastDayOfMonth(DateTime.fromMillisecondsSinceEpoch(transDate)).millisecondsSinceEpoch;

      // query budget for thsi transaction
      var budgets = await db.query(_tableBudget, where: "$_budgetCategoryId = $catId AND ($_budgetStart BETWEEN $startDate AND $endDate)");
      if(budgets == null) break;
      if(budgets.isEmpty) break;

      // update budget now
      await _recalculateBudget(db, budgets[0]);
    } while(false);
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

    String type = TransactionType.typeExpense.map((f) => "${f.id}").toString();
    var spent = 0.0;
    var rawSpend = await db.rawQuery("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE $_transAcc = $accountId AND $_transType in $type");
    if(rawSpend != null
        && rawSpend.isNotEmpty
        && rawSpend.first != null
        && rawSpend.first.values != null
        && rawSpend.first.values.isNotEmpty
        && rawSpend.first.values.first != null) spent = rawSpend.first.values.first;

    type = TransactionType.typeIncome.map((f) => "${f.id}").toString();
    var earn = 0.0;
    var rawEarn = await db.rawQuery("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE $_transAcc = $accountId AND $_transType in $type");
    if(rawEarn != null
        && rawEarn.isNotEmpty
        && rawEarn.first != null
        && rawEarn.first.values != null
        && rawEarn.first.values.isNotEmpty
        && rawEarn.first.values.first != null) earn = rawEarn.first.values.first;

    var balance = initialBalance + earn - spent;

    db.update(_tableAccounts, {
      _accBalance: balance,
      _accSpent: spent,
      _accEarned: earn
    }, where: "$_id = ?", whereArgs: [accountId]);
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


