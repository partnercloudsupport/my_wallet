import 'package:my_wallet/data/firebase/common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'dart:async';

const _data = "data";

DatabaseReference _database;

bool _isInit = false;
bool _isDbSetup = false;

FirebaseApp _app;

List<StreamSubscription> subs = [];

Future<void> init(FirebaseApp app, {String homeProfile}) async {
  if (_isInit) return;

  _isInit = true;
  if(_app != null) _app = app;

  if (homeProfile != null && homeProfile.isNotEmpty) setupDatabase(homeProfile);
}

Future<void> setupDatabase(final String homeKey) async {
  return _lock.synchronized(() async {
    if (_isDbSetup) return;

    _isDbSetup = true;

    _database = FirebaseDatabase(app: _app).reference().child(_data).child(homeKey);

    // register listener to Account
    subs.add(_database.reference().child(tblAccount).onChildAdded.listen(_onAccountAdded));
    subs.add(_database.reference().child(tblAccount).onChildChanged.listen(_onAccountChanged));
    subs.add(_database.reference().child(tblAccount).onChildMoved.listen(_onAccountMoved));
    subs.add(_database.reference().child(tblAccount).onChildRemoved.listen(_onAccountRemoved));

    // register listener to Category
    subs.add(_database.reference().child(tblCategory).onChildAdded.listen(_onCategoryAdded));
    subs.add(_database.reference().child(tblCategory).onChildChanged.listen(_onCategoryChanged));
    subs.add(_database.reference().child(tblCategory).onChildMoved.listen(_onCategoryMoved));
    subs.add(_database.reference().child(tblCategory).onChildRemoved.listen(_onCategoryRemoved));

    // register listener to Transactions
    subs.add(_database.reference().child(tblTransaction).onChildAdded.listen(_onTransactionAdded));
    subs.add(_database.reference().child(tblTransaction).onChildChanged.listen(_onTransactionChanged));
    subs.add(_database.reference().child(tblTransaction).onChildMoved.listen(_onTransactionMoved));
    subs.add(_database.reference().child(tblTransaction).onChildRemoved.listen(_onTransactionRemoved));

    subs.add(_database.reference().child(tblUser).onChildAdded.listen(_onUserAdded));
    subs.add(_database.reference().child(tblUser).onChildChanged.listen(_onUserChanged));
    subs.add(_database.reference().child(tblUser).onChildMoved.listen(_onUserMoved));
    subs.add(_database.reference().child(tblUser).onChildRemoved.listen(_onUserRemoved));
  });
}

// ####################################################################################################
// private helper
Map<String, dynamic> _AccountToMap(Account acc) {
  return {fldName: acc.name, fldType: acc.type.id, fldBalance: acc.balance, fldCurrency: acc.currency};
}

Account _snapshotToAccount(DataSnapshot snapshot) {
  return Account(_toId(snapshot), snapshot.value[fldName], double.parse("${snapshot.value[fldBalance]}"), AccountType.all[snapshot.value[fldType]], snapshot.value[fldCurrency]);
}

Map<String, dynamic> _CategoryToMap(AppCategory cat) {
  return {fldName: cat.name, fldColorHex: cat.colorHex, fldBalance: cat.balance};
}

Map<String, dynamic> _UserToMap(User user, {int color}) {
  return {fldUuid: user.uuid, fldEmail: user.email, fldDisplayName: user.displayName, fldPhotoUrl: user.photoUrl, fldColor: color != null ? color : user.color};
}

AppCategory _snapshotToCategory(DataSnapshot snapshot) {
  return AppCategory(_toId(snapshot), snapshot.value[fldName], snapshot.value[fldColorHex], double.parse("${snapshot.value[fldBalance]}"));
}

Map<String, dynamic> _TransactionToMap(AppTransaction trans) {
  return {fldDateTime: trans.dateTime.millisecondsSinceEpoch, fldAccountId: trans.accountId, fldCategoryId: trans.categoryId, fldAmount: trans.amount, fldDesc: trans.desc, fldType: trans.type.id, fldUuid: trans.userUid};
}

AppTransaction _snapshotToTransaction(DataSnapshot snapshot) {
  return AppTransaction(_toId(snapshot), DateTime.fromMillisecondsSinceEpoch(snapshot.value[fldDateTime]), snapshot.value[fldAccountId], snapshot.value[fldCategoryId], double.parse("${snapshot.value[fldAmount]}"), snapshot.value[fldDesc], TransactionType.all[snapshot.value[fldType]], snapshot.value[fldUuid]);
}

int _toId(DataSnapshot snapshot) {
  return int.parse(snapshot.key);
}

void _onAccountAdded(Event event) {
  db.insertAccount(_snapshotToAccount(event.snapshot)).catchError((e) => _onAccountChanged(event));
}

void _onAccountChanged(Event event) {
  db.updateAccount(_snapshotToAccount(event.snapshot));
}

void _onAccountMoved(Event event) {}

void _onAccountRemoved(Event event) {
  db.deleteAccount(int.parse(event.snapshot.key));
}

void _onCategoryAdded(Event event) {
  db.insertCagetory(_snapshotToCategory(event.snapshot)).catchError((e) => _onCategoryChanged(event));
}

void _onCategoryChanged(Event event) {
  db.updateCategory(_snapshotToCategory(event.snapshot));
}

void _onCategoryMoved(Event event) {}

void _onCategoryRemoved(Event event) {
  db.deleteCategory(_toId(event.snapshot));
}

void _onTransactionAdded(Event event) {
  db.insertTransaction(_snapshotToTransaction(event.snapshot)).catchError((e) => _onTransactionChanged(event));
}

void _onTransactionChanged(Event event) {
  db.updateTransaction(_snapshotToTransaction(event.snapshot));
}

void _onTransactionMoved(Event event) {}

void _onTransactionRemoved(Event event) {
  db.deleteTransaction(_toId(event.snapshot));
}

void _onUserAdded(Event event) {
  db.insertUser(snapshotToUser(event.snapshot)).catchError((e) => _onUserChanged(event));
}

void _onUserChanged(Event event) {
  db.updateUser(snapshotToUser(event.snapshot));
}

void _onUserMoved(Event event) {
}

void _onUserRemoved(Event event) {
  db.deleteUser(event.snapshot.value[fldUuid]);
}


// ####################################################################################################
// Account
Lock _lock = Lock();

Future<bool> addAccount(Account acc) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblAccount);

    var result = await _ref.child("${acc.id}").runTransaction((data) async {
      data.value = _AccountToMap(acc);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateAccount(Account acc) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblAccount);

    await _ref.child("${acc.id}").update(_AccountToMap(acc));

    return true;
  });
}

Future<bool> deleteAccount(Account acc) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblAccount);

    await _ref.child("${acc.id}").remove();

    return true;
  });
}

// ####################################################################################################
// Transaction
Future<bool> addTransaction(AppTransaction transaction) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblTransaction);

    var result = await _ref.child("${transaction.id}").runTransaction((data) async {
      data.value = _TransactionToMap(transaction);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateTransaction(AppTransaction trans) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblTransaction);

    await _ref.child("${trans.id}").update(_TransactionToMap(trans));

    return true;
  });
}

Future<bool> deleteTransaction(AppTransaction trans) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblTransaction);

    await _ref.child("${trans.id}").remove();

    return true;
  });
}

// ####################################################################################################
// Category
Future<bool> addCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblCategory);

    var result = await _ref.child("${cat.id}").runTransaction((data) async {
      data.value = _CategoryToMap(cat);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblCategory);

    await _ref.child("${cat.id}").update(_CategoryToMap(cat));

    return true;
  });
}

Future<bool> deleteCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblCategory);

    await _ref.child("${cat.id}").remove();

    return true;
  });
}

// ####################################################################################################
// User
Future<bool> addUser(User user, {int color}) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblUser);

    var result = await _ref.child("${user.uuid}").runTransaction((data) async {
      data.value = _UserToMap(user, color : color);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateUser(User user) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblUser);

    await _ref.child("${user.uuid}").update(_UserToMap(user));

    return true;
  });
}

Future<bool> deleteUser(User user) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(tblUser);

    await _ref.child("${user.uuid}").remove();

    return true;
  });
}

Future<bool> removeRefenrence() async {
  return _lock.synchronized(() async {
    if(subs != null) subs.forEach((f) async => await f.cancel());

    _isDbSetup = false;
  });
}



