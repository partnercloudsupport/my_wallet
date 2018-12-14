import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_wallet/data/data.dart';
import 'package:synchronized/synchronized.dart';
import 'package:my_wallet/data/data_observer.dart';

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
final _transDesc = "_transactionDescription";
final _transType = "_transactionType";
final _transUid = "_transactionUserUid";

// table category
final _tableCategory = tableCategory;
final _catId = _id;
final _catName = "_name";
final _catColorHex = "_colorHex";

// table budget
final _tableBudget = tableBudget;
final _budgetId = _id;
final _budgetCategoryId = "_catId";
final _budgetPerMonth = "_budgetPerMonth";
final _budgetStart = "_budgetStart";
final _budgetEnd = "_budgetEnd";

final _tableUser = tableUser;
final _userUid = _id;
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

Future<List<AppTransaction>> queryTransactions({int id}) async {
  String where;

  if(id != null) where = "$_transID = $id";

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

Future<List<AppTransaction>> queryTransactionForCategory(int categoryId) async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transCategory = ?", whereArgs: [categoryId]));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionForAccount(int accountId) async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableTransactions, where: "$_transAcc = ?", whereArgs: [ accountId]));

  return map == null ? [] : map.map((f) => _toTransaction(f)).toList();
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

Future<List<AppCategory>> queryCategoryWithTransaction({DateTime from, DateTime to, List<TransactionType> type, bool filterZero}) async {
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

  return map != null ? map.map((f) => _toTransaction(f)).toList() : null;
}

Future<List<User>> queryUserWithUuid(String uuid) async {
  List<Map<String, dynamic>> map = await _lock.synchronized(() => db._query(_tableUser, where: "$_userUid = ?", whereArgs: [ uuid ]));

  return map == null ? null : map.map((f) => _toUser(f)).toList();
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

Future<int> deleteUser(String uid) {
  return _lock.synchronized(() => db._delete(tableUser, "$_userUid = ?", [uid]));
}

Future<int> deleteUsers(List<String> uids) {
  return _lock.synchronized(() => db._delete(tableUser, "$_userUid = ?", uids));
}

Future<void> dropAllTables() {
  return _lock.synchronized(() => db._deleteDb());
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

Future<int> updateUser(User user) {
  return _lock.synchronized(() => db._update(tableUser, _userToMap(user), "$_userUid = ?", [user.uuid]));
}

// ################################################################################################################
// private helper
// ################################################################################################################
AppTransaction _toTransaction(Map<String, dynamic> map) {
  return AppTransaction(map[_transID], DateTime.fromMillisecondsSinceEpoch(map[_transDateTime]), map[_transAcc], map[_transCategory], map[_transAmount], map[_transDesc], TransactionType.all[map[_transType]], map[_transUid]);
}

Account _toAccount(Map<String, dynamic> map) {
  return new Account(map[_accID], map[_accName], map[_accBalance], AccountType.all[map[_accType]], map[_accCurrency]);
}

AppCategory _toCategory(Map<String, dynamic> map) {
  return AppCategory(
    map[_catId],
    map[_catName],
    map[_catColorHex],
    0,
  );
}

Budget _toBudget(Map<String, dynamic> map) {
  return Budget(map[_budgetId], map[_budgetCategoryId], map[_budgetPerMonth], map[_budgetStart], map[_budgetEnd]);
}

User _toUser(Map<String, dynamic> map) {
  return User(
    map[_userUid],
    map[_userEmail],
    map[_userDisplayName],
    map[_userPhotoUrl],
    map[_userColor],
  );
}

Map<String, dynamic> _transactionToMap(AppTransaction transaction) {
  return {_transID: transaction.id, _transDateTime: transaction.dateTime.millisecondsSinceEpoch, _transAcc: transaction.accountId, _transCategory: transaction.categoryId, _transAmount: transaction.amount, _transDesc: transaction.desc, _transType: transaction.type.id, _transUid: transaction.userUid};
}

Map<String, dynamic> _accountToMap(Account acc) {
  return {_accID: acc.id, _accName: acc.name, _accBalance: acc.balance, _accType: acc.type.id, _accCurrency: acc.type.id};
}

Map<String, dynamic> _categoryToMap(AppCategory cat) {
  return {
    _catId: cat.id,
    _catName: cat.name,
    _catColorHex: cat.colorHex,
  };
}

Map<String, dynamic> _bugetToMap(Budget budget) {
  return {_budgetId: budget.id, _budgetCategoryId: budget.categoryId, _budgetPerMonth: budget.budgetPerMonth, _budgetStart: budget.budgetStart, _budgetEnd: budget.budgetEnd};
}

Map<String, dynamic> _userToMap(User user) {
  return {
    _userUid: user.uuid,
    _userEmail: user.email,
    _userDisplayName: user.displayName,
    _userPhotoUrl: user.photoUrl,
  _userColor: user.color,
  };
}
// #############################################################################################################################
// private database handler
// #############################################################################################################################
class _Database {
  Database db;
  Map<String, List<DatabaseObservable>> _watchers = {};
//  List<DatabaseObservable> _accountWatchers = [];
//  List<DatabaseObservable> _categoryWatchers = [];
//  List<DatabaseObservable> _transactionWatchers = [];
//  List<DatabaseObservable> _budgetWatchers  = [];

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
          $_transDesc TEXT,
          $_transType INTEGER NOT NULL,
          $_transUid TEXT NOT NULL
          )""");

      await db.execute("""
        CREATE TABLE $_tableCategory (
        $_catId INTEGER PRIMARY KEY,
        $_catName TEXT NOT NULL,
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

      await db.execute("""
        CREATE TABLE $_tableUser (
        $_userUid TEXT NOT NULL PRIMARY KEY,
        $_userDisplayName TEXT NOT NULL,
        $_userEmail TEXT NOT NULL,
        $_userPhotoUrl TEXT,
        $_userColor INTEGER
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

    return id == null ? 0 : id + 1;
  }

  Future<List<Map<String, dynamic>>> _executeSql(String sql) async {
    Database db = await _openDatabase();

    var result = await db.rawQuery(sql);

    await db.close();

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

    await db.close();

    _notifyObservers(table);

    return result;
  }

  Future<int> _update(String table, Map<String, dynamic> item, String where, List whereArgs) async {
    Database db = await _openDatabase();

    var result = await db.update(table, item, where: where, whereArgs: whereArgs);

    await db.close();

    _notifyObservers(table);

    return result;
  }

  Future<void> _deleteDb() async {

    Database db = await _openDatabase();

    String path = db.path;

    // close database before deleting it
    await db.close();

    await deleteDatabase(path);
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
//        switch(f) {
//          case tableAccount: _accountWatchers.remove(observable); break;
//          case tableCategory: _categoryWatchers.remove(observable); break;
//          case tableTransactions: _transactionWatchers.remove(observable); break;
//          case tableBudget: _budgetWatchers.remove(observable); break;
//          case tableUser: _budgetWatchers.remove(obser)
//        }
      });
    }
  }
}


