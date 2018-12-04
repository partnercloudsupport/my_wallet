import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_wallet/database/data.dart';
import 'package:synchronized/synchronized.dart';
import 'package:my_wallet/data_observer.dart';

// #############################################################################################################################
// database manager
// #############################################################################################################################
final _id = "_id";

// table Account
final _tableAccounts = tableAccount;
final _accID = _id;
final _accName = "_name";
final _accBalance = "_balance";
final _accType = "_type";
final _accCurrency = "_currency";

// table transaction
final _tableTransactions = tableTransactions;
final _transID = _id;
final _transDateTime = "_dateTime";
final _transAcc = "_accountId";
final _transCategory = "_categoryId";
final _transAmount = "_amount";
final _transDesc = "transactionDescription";
final _transType = "transactionType";

// table category
final _tableCategory = tableCategory;
final _catId = _id;
final _catName = "_name";
final _catTransactionType = "_transactionType";
final _catColorHex = "_colorHex";

// table budget
final _tableBudget = tableBudget;
final _budgetId = _id;
final _budgetCategoryId = "_catId";
final _budgetPerMonth = "_budgetPerMonth";
final _budgetStart = "_budgetStart";
final _budgetEnd = "_budgetEnd";

_Database db = _Database();
Lock _lock = Lock();

void registerDatabaseObservable(String table, DatabaseObservable observable) {
  _watchers.update(table,
          (curObservers) {
        curObservers.add(observable);
      }, ifAbsent: () => [observable]);
}

void unregisterDatabaseObservable(String table, DatabaseObservable observable) {
  _watchers[table] ?? _watchers[table].remove(observable);
}

// ------------------------------------------------------------------------------------------------------------------------
// other SQL helper methods
Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, TransactionType type) async {
  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}) AND $_transType = ${type.index}"));

  return sum[0].values.first;
}

Future<double> sumAllAccountBalance() async {
  var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_accBalance) FROM $_tableAccounts"));

  return sum[0].values.first;
}

Future<double> sumTransactionsByDay(DateTime day, TransactionType type) async {
    var startOfDay = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    var endOfDay = DateTime(day.year, day.month, day.day + 1).millisecondsSinceEpoch;

    var sum = await _lock.synchronized(() => db._executeSql("SELECT SUM($_transAmount) FROM $_tableTransactions WHERE ($_transDateTime BETWEEN $startOfDay AND $endOfDay) AND $_transType = ${type.index}"));

    return sum[0].values.first;
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
    whereArgs = [type.index];
  } else if (id != null) {
    where = "$_accID = ?";
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

Future<List<AppTransaction>> queryTransactions() async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionsBetweenDates(DateTime from, DateTime to, {TransactionType type}) async {
  String where = from != null && to != null ? "$_transDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}" : null;

  if(type != null) {
    where = "($where) AND $_transType = ${type.index}";
  }

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: where));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForCategory(int categoryId) async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transCategory = ?", whereArgs: [categoryId]));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForAccount(int accountId) async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transAcc = ?", whereArgs: [ accountId]));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppCategory>> queryCategory({int id, int transactionType}) async {
  String where;
  List<int> whereArg;

  if (id == null && transactionType == null) {
    where = null;
    whereArg = null;
  } else if (transactionType != null) {
    where = "$_catTransactionType = ?";
    whereArg = [transactionType];
  } else {
    where = "$_id = ?";
    whereArg = [id];
  }
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableCategory, where: where, whereArgs: whereArg));

  if (map != null) return map.map((f) => _toCategory(f)).toList();

  return null;
}

Future<List<AppCategory>> queryCategoryWithTransaction({DateTime from, DateTime to, TransactionType type, bool filterZero}) async {
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
    where = "($where) AND $_transType = ${type.index}";
  }

  List<Map<String, dynamic>> catMaps = await _lock.synchronized(() => db._query(_tableCategory));

  List<Map<String, dynamic>> transMap = await _lock.synchronized(() => db._query(_tableTransactions, where: where));

  List<AppTransaction> trans = transMap == null ? [] : transMap.map((f) => _toTransaction(f)).toList();

  List<AppCategory> appCats = [];

  appCats = catMaps == null
      ? []
      : catMaps.map((f) {
          var total = 0.0;
          var catId = f[_catId];
          trans.forEach((trans) => total += trans.categoryId == catId ? trans.amount : 0.0);

          return AppCategory(
            f[_catId],
            f[_catName],
            TransactionType.values[f[_catTransactionType]],
            f[_catColorHex],
            total,
          );
        }).toList();

  if (filterZero) appCats.removeWhere((f) => f.balance == 0);

  return appCats;
}

Future<List<AppTransaction>> queryForDate(DateTime day) async {
  DateTime startOfDay = DateTime(day.year, day.month, day.day, 0, 0);

  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transDateTime BETWEEN ? AND ?", whereArgs: [startOfDay.millisecondsSinceEpoch, startOfDay.add(Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999)).millisecondsSinceEpoch]));

  if (map != null) return map.map((f) => _toTransaction(f)).toList();

  return null;
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

// ------------------------------------------------------------------------------------------------------------------------
// delete
Future<int> deleteAccount(int id) {
  return _lock.synchronized(() => db._delete(_tableAccounts, "$_accID = ?", [id]));
}

Future<int> deleteAccounts(List<int> ids) {
  return _lock.synchronized(() => db._delete(_tableAccounts, "$_accID = ?", ids));
}

Future<int> deleteTransaction(int id) {
  return _lock.synchronized(() => db._delete(_tableTransactions, "$_transID = ?", [id]));
}

Future<int> deleteTransactions(List<int> ids) {
  return _lock.synchronized(() => db._delete(_tableTransactions, "$_transID = ?", ids));
}

Future<int> deleteCategory(int id) {
  return _lock.synchronized(() => db._delete(_tableTransactions, "$_catId = ?", [id]));
}

Future<int> deleteCategories(List<int> ids) {
  return _lock.synchronized(() => db._delete(_tableTransactions, "$_catId = ?", ids));
}

// ------------------------------------------------------------------------------------------------------------------------
// update
Future<int> updateAccount(Account acc) {
  return _lock.synchronized(() => db._update(_tableAccounts, _accountToMap(acc), "$_accID = ?", [acc.id]));
}

Future<int> updateTransaction(AppTransaction transaction) {
  return _lock.synchronized(() => db._update(_tableTransactions, _transactionToMap(transaction), "$_transID = ?", [transaction.id]));
}

Future<int> updateCategory(AppCategory cat) {
  // search for category's parent
  return _lock.synchronized(() => db._update(_tableCategory, _categoryToMap(cat), "$_catId = ?", [cat.id]));
}

// private helper
AppTransaction _toTransaction(Map<String, dynamic> map) {
  return AppTransaction(map[_transID], DateTime.fromMillisecondsSinceEpoch(map[_transDateTime]), map[_transAcc], map[_transCategory], map[_transAmount], map[_transDesc], TransactionType.values[map[_transType]]);
}

Account _toAccount(Map<String, dynamic> map) {
  return new Account(map[_accID], map[_accName], map[_accBalance], AccountType.values[map[_accType]], map[_accCurrency]);
}

AppCategory _toCategory(Map<String, dynamic> map) {
  return AppCategory(
    map[_catId],
    map[_catName],
    TransactionType.values[map[_catTransactionType]],
    map[_catColorHex],
    0,
  );
}

Budget _toBudget(Map<String, dynamic> map) {
  return Budget(map[_budgetId], map[_budgetCategoryId], map[_budgetPerMonth], map[_budgetStart], map[_budgetEnd]);
}

Map<String, dynamic> _transactionToMap(AppTransaction transaction) {
  return {_transID: transaction.id, _transDateTime: transaction.dateTime.millisecondsSinceEpoch, _transAcc: transaction.accountId, _transCategory: transaction.categoryId, _transAmount: transaction.amount, _transDesc: transaction.desc, _transType: transaction.type.index};
}

Map<String, dynamic> _accountToMap(Account acc) {
  return {_accID: acc.id, _accName: acc.name, _accBalance: acc.balance, _accType: acc.type.index, _accCurrency: acc.type.index};
}

Map<String, dynamic> _categoryToMap(AppCategory cat) {
  return {
    _catId: cat.id,
    _catName: cat.name,
    _catTransactionType: cat.transactionType.index,
    _catColorHex: cat.colorHex,
  };
}

Map<String, dynamic> _bugetToMap(Budget budget) {
  return {_budgetId: budget.id, _budgetCategoryId: budget.categoryId, _budgetPerMonth: budget.budgetPerMonth, _budgetStart: budget.budgetStart, _budgetEnd: budget.budgetEnd};
}
//}

// #############################################################################################################################
// private database handler
// #############################################################################################################################
Map<String, List<DatabaseObservable>> _watchers = {};
class _Database {
  Database db;

  Future<Database> _openDatabase() async {
    String dbPath = join((await getApplicationDocumentsDirectory()).path, "MyWalletDb");
    db = await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      await db.execute("""
            CREATE TABLE $_tableAccounts (
              $_accID INTEGER PRIMARY KEY,
              $_accName TEXT NOT NULL,
              $_accBalance DOUBLE NOT NULL,
              $_accType INTEGER NOT NULL,
              $_accCurrency TEXT NOT NULL
            )""");

      await db.execute("""
          CREATE TABLE $_tableTransactions (
          $_transID INTEGER PRIMARY KEY,
          $_transDateTime LONG NOT NULL,
          $_transAcc INTEGER NOT NULL,
          $_transCategory INTEGER NOT NULL,
          $_transAmount DOUBLE NOT NULL,
          $_transDesc TEXT NOT NULL,
          $_transType INTEGER NOT NULL
          )""");

      await db.execute("""
        CREATE TABLE $_tableCategory (
        $_catId INTEGER PRIMARY KEY,
        $_catName TEXT NOT NULL,
        $_catTransactionType INTEGER NOT NULL,
        $_catColorHex TEXT NOT NULL
        )
        """);

      await db.execute("""
        CREATE TABLE $_tableBudget (
        $_budgetId INTEGER PRIMARY KEY,
        $_budgetCategoryId INTEGER NOT NULL,
        $_budgetPerMonth DOUBLE NOT NULL,
        $_budgetStart INTEGER NOT NULL,
        $_budgetEnd INTEGER
        )
        """);
    });

    return db;
  }

  Future<int> _generateId(String table) async {
    Database db = await _openDatabase();

    int id = 0;

    var ids = await db.rawQuery("SELECT MAX($_id) FROM $table");

    if(ids.length >= 0) {
      id = ids[0].values.first;
    }

    await db.close();

    return id + 1;
  }

  Future<List<Map<String, dynamic>>> _executeSql(String sql) async {
    Database db = await _openDatabase();

    var result = await db.rawQuery(sql);

    db.close();

    return result;
  }

  Future<List<Map<String, dynamic>>> _query(String table, {String where, List whereArgs}) async {
    Database db = await _openDatabase();

    List<Map<String, dynamic>> map = await db.query(table, where: where, whereArgs: whereArgs);

    await db.close();

    return map;
  }

  Future<int> _insert(String table, {Map<String, dynamic> item, List<Map<String, dynamic>> items}) async {
    Database db = await _openDatabase();

    var result = -1;

    if (item != null) {
      if (item[_id] == null) {
        var id = await _generateId(table);
        item.putIfAbsent(_id, () => id);
      }
      result = await db.insert(table, item);
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
      }
    }

    await db.close();

    _notifyObservers(table);

    return result;
  }

  Future<int> _delete(String table, String where, List whereArgs) async {
    Database db = await _openDatabase();

    var result = await db.delete(table, where: where, whereArgs: whereArgs);

    db.close();

    _notifyObservers(table);

    return result;
  }

  Future<int> _update(String table, Map<String, dynamic> item, String where, List whereArgs) async {
    Database db = await _openDatabase();

    var result = await db.update(table, item, where: where, whereArgs: whereArgs);

    db.close();

    _notifyObservers(table);

    return result;
  }

  void _notifyObservers(String table) {
    var observables = _watchers[table];

    if(observables != null) {
      observables.forEach((observable) => observable.onDatabaseUpdate());
    }
  }
}


