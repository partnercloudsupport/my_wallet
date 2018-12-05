import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:firebase_database/firebase_database.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/database/firebase_config.dart' as fbConfig;
import 'package:synchronized/synchronized.dart';

FirebaseDatabase _database;
bool _isInit = false;

const _Account = "Account";
const _Transaction = "Transaction";
const _Category = "Category";

const _name = "name";
const _type = "type";
const _balance = "balance";
const _currency = "currency";
const _transactionType = "transactionType";
const _colorHex = "colorHex";
const _dateTime = "dateTime";
const _accountId = "accountId";
const _categoryId = "categoryId";
const _amount = "amount";
const _desc = "desc";
void init() async {
  if (_isInit) return;

  _isInit = true;
  FirebaseApp _app = await FirebaseApp.configure(
      name: Platform.isIOS ? "MyWallet" : "My Wallet",
      options: Platform.isIOS
          ? const FirebaseOptions(
        googleAppID: fbConfig.firebase_ios_app_id,
        gcmSenderID: fbConfig.firebase_gcm_sender_id,
        projectID: fbConfig.firebase_project_id,
        databaseURL: fbConfig.firebase_database_url,
      )
          : const FirebaseOptions(
        googleAppID: fbConfig.firebase_android_app_id,
        apiKey: fbConfig.firebase_api_key,
        projectID: fbConfig.firebase_project_id,
        databaseURL: fbConfig.firebase_database_url,
      ));
  _database = FirebaseDatabase(app: _app);

  // register listener to Account
  _database
      .reference()
      .child(_Account)
      .onChildAdded
      .listen(_onAccountAdded);
  _database
      .reference()
      .child(_Account)
      .onChildChanged
      .listen(_onAccountChanged);
  _database
      .reference()
      .child(_Account)
      .onChildMoved
      .listen(_onAccountMoved);
  _database
      .reference()
      .child(_Account)
      .onChildRemoved
      .listen(_onAccountRemoved);

  // register listener to Category
  _database
      .reference()
      .child(_Category)
      .onChildAdded
      .listen(_onCategoryAdded);
  _database
      .reference()
      .child(_Category)
      .onChildChanged
      .listen(_onCategoryChanged);
  _database
      .reference()
      .child(_Category)
      .onChildMoved
      .listen(_onCategoryMoved);
  _database
      .reference()
      .child(_Category)
      .onChildRemoved
      .listen(_onCategoryRemoved);

  // register listener to Transactions
  _database
      .reference()
      .child(_Transaction)
      .onChildAdded
      .listen(_onTransactionAdded);
  _database
      .reference()
      .child(_Transaction)
      .onChildChanged
      .listen(_onTransactionChanged);
  _database
      .reference()
      .child(_Transaction)
      .onChildMoved
      .listen(_onTransactionMoved);
  _database
      .reference()
      .child(_Transaction)
      .onChildRemoved
      .listen(_onTransactionRemoved);
}

// ####################################################################################################
// private helper
Map<String, dynamic> _AccountToMap(Account acc) {
  return {
    _name: acc.name,
    _type: acc.type.id,
    _balance: acc.balance,
    _currency: acc.currency
  };
}

Account _snapshotToAccount(DataSnapshot snapshot) {
  return Account(
      _toId(snapshot),
      snapshot.value[_name],
      double.parse("${snapshot.value[_balance]}"),
      AccountType.all[snapshot.value[_type]],
      snapshot.value[_currency]
  );
}

Map<String, dynamic> _CategoryToMap(AppCategory cat) {
  return {
    _name: cat.name,
    _colorHex: cat.colorHex,
    _balance: cat.balance
  };
}

AppCategory _snapshotToCategory(DataSnapshot snapshot) {
  return AppCategory(
      _toId(snapshot),
      snapshot.value[_name],
      snapshot.value[_colorHex],
      double.parse("${snapshot.value[_balance]}")
  );
}

Map<String, dynamic> _TransactionToMap(AppTransaction trans) {
  return {
    _dateTime: trans.dateTime.millisecondsSinceEpoch,
    _accountId: trans.accountId,
    _categoryId: trans.categoryId,
    _amount: trans.amount,
    _desc: trans.desc,
    _type: trans.type.index
  };
}

AppTransaction _snapshotToTransaction(DataSnapshot snapshot) {
  return AppTransaction(
      _toId(snapshot),
      DateTime.fromMillisecondsSinceEpoch(snapshot.value[_dateTime]),
      snapshot.value[_accountId],
      snapshot.value[_categoryId],
      double.parse("${snapshot.value[_amount]}"),
      snapshot.value[_desc],
      TransactionType.values[snapshot.value[_type]]
  );
}

int _toId(DataSnapshot snapshot) {
  return int.parse(snapshot.key);
}

void _onAccountAdded(Event event) {
  db.insertAccount(_snapshotToAccount(event.snapshot))
      .catchError((e) => _onAccountChanged(event));
}

void _onAccountChanged(Event event) {
  db.updateAccount(_snapshotToAccount(event.snapshot));
}

void _onAccountMoved(Event event) {
}

void _onAccountRemoved(Event event) {
  db.deleteAccount(int.parse(event.snapshot.key));
}

void _onCategoryAdded(Event event) {
  db.insertCagetory(_snapshotToCategory(event.snapshot))
      .catchError((e) => _onCategoryChanged(event));
}

void _onCategoryChanged(Event event) {
  db.updateCategory(_snapshotToCategory(event.snapshot));
}

void _onCategoryMoved(Event event) {

}

void _onCategoryRemoved(Event event) {
  db.deleteCategory(_toId(event.snapshot));
}

void _onTransactionAdded(Event event) {
  db.insertTransaction(_snapshotToTransaction(event.snapshot))
      .catchError((e) => _onTransactionChanged(event));
}

void _onTransactionChanged(Event event) {
  db.updateTransaction(_snapshotToTransaction(event.snapshot));
}

void _onTransactionMoved(Event event) {

}

void _onTransactionRemoved(Event event) {
  db.deleteTransaction(_toId(event.snapshot));
}

// ####################################################################################################
// Account
Lock _lock = Lock();
Future<bool> addAccount(Account acc) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Account);

    var result = await _ref.child("${acc.id}").runTransaction((data) async {
      data.value = _AccountToMap(acc);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateAccount(Account acc) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Account);

    await _ref.child("${acc.id}").update(_AccountToMap(acc));

    return true;
  });
}

Future<bool> deleteAccount(Account acc) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Account);

    await _ref.child("${acc.id}").remove();

    return true;
  });
}

// ####################################################################################################
// Transaction
Future<bool> addTransaction(AppTransaction transaction) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Transaction);

    var result = await _ref.child("${transaction.id}").runTransaction((data) async {
      data.value = _TransactionToMap(transaction);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateTransaction(AppTransaction trans) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Transaction);

    await _ref.child("${trans.id}").update(_TransactionToMap(trans));

    return true;
  });
}

Future<bool> deleteTransaction(AppTransaction trans) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Transaction);

    await _ref.child("${trans.id}").remove();

    return true;
  });
}

// ####################################################################################################
// Category
Future<bool> addCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Category);

    var result = await _ref.child("${cat.id}").runTransaction((data) async {
      data.value = _CategoryToMap(cat);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Category);

    await _ref.child("${cat.id}").update(_CategoryToMap(cat));

    return true;
  });
}

Future<bool> deleteCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_Category);

    await _ref.child("${cat.id}").remove();

    return true;
  });
}