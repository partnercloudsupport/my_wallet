import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:firebase_database/firebase_database.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase_config.dart' as fbConfig;
import 'package:synchronized/synchronized.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_wallet/data/data.dart';

FirebaseDatabase _database;
FirebaseAuth _auth;
bool _isInit = false;

const _Account = "Account";
const _Transaction = "Transaction";
const _Category = "Category";
const _User = "User";

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
const _email = "email";
const _displayName = "displayName";
const _photoUrl = "photoUrl";
const _uuid = "uuid";

Future<void> init() async {
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
  _auth = FirebaseAuth.fromApp(_app);

  // register listener to Account
  _database.reference().child(_Account).onChildAdded.listen(_onAccountAdded);
  _database.reference().child(_Account).onChildChanged.listen(_onAccountChanged);
  _database.reference().child(_Account).onChildMoved.listen(_onAccountMoved);
  _database.reference().child(_Account).onChildRemoved.listen(_onAccountRemoved);

  // register listener to Category
  _database.reference().child(_Category).onChildAdded.listen(_onCategoryAdded);
  _database.reference().child(_Category).onChildChanged.listen(_onCategoryChanged);
  _database.reference().child(_Category).onChildMoved.listen(_onCategoryMoved);
  _database.reference().child(_Category).onChildRemoved.listen(_onCategoryRemoved);

  // register listener to Transactions
  _database.reference().child(_Transaction).onChildAdded.listen(_onTransactionAdded);
  _database.reference().child(_Transaction).onChildChanged.listen(_onTransactionChanged);
  _database.reference().child(_Transaction).onChildMoved.listen(_onTransactionMoved);
  _database.reference().child(_Transaction).onChildRemoved.listen(_onTransactionRemoved);

  _database.reference().child(_User).onChildAdded.listen(_onUserAdded);
  _database.reference().child(_User).onChildChanged.listen(_onUserChanged);
  _database.reference().child(_User).onChildMoved.listen(_onUserMoved);
  _database.reference().child(_User).onChildRemoved.listen(_onUserRemoved);
}

// ####################################################################################################
// private helper
Map<String, dynamic> _AccountToMap(Account acc) {
  return {_name: acc.name, _type: acc.type.id, _balance: acc.balance, _currency: acc.currency};
}

Account _snapshotToAccount(DataSnapshot snapshot) {
  return Account(_toId(snapshot), snapshot.value[_name], double.parse("${snapshot.value[_balance]}"), AccountType.all[snapshot.value[_type]], snapshot.value[_currency]);
}

Map<String, dynamic> _CategoryToMap(AppCategory cat) {
  return {_name: cat.name, _colorHex: cat.colorHex, _balance: cat.balance};
}

Map<String, dynamic> _UserToMap(User user) {
  return {_uuid: user.uuid, _email: user.email, _displayName: user.displayName, _photoUrl: user.photoUrl};
}

AppCategory _snapshotToCategory(DataSnapshot snapshot) {
  return AppCategory(_toId(snapshot), snapshot.value[_name], snapshot.value[_colorHex], double.parse("${snapshot.value[_balance]}"));
}

Map<String, dynamic> _TransactionToMap(AppTransaction trans) {
  return {_dateTime: trans.dateTime.millisecondsSinceEpoch, _accountId: trans.accountId, _categoryId: trans.categoryId, _amount: trans.amount, _desc: trans.desc, _type: trans.type.id};
}

AppTransaction _snapshotToTransaction(DataSnapshot snapshot) {
  return AppTransaction(_toId(snapshot), DateTime.fromMillisecondsSinceEpoch(snapshot.value[_dateTime]), snapshot.value[_accountId], snapshot.value[_categoryId], double.parse("${snapshot.value[_amount]}"), snapshot.value[_desc], TransactionType.all[snapshot.value[_type]]);
}

User _snapshotToUser(DataSnapshot snapshot) {
  return User(snapshot.value[_uuid], snapshot.value[_email], snapshot.value[_displayName], snapshot.value[_photoUrl]);
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
  db.insertUser(_snapshotToUser(event.snapshot)).catchError((e) => _onUserChanged(event));
}

void _onUserChanged(Event event) {
  db.updateUser(_snapshotToUser(event.snapshot));
}

void _onUserMoved(Event event) {

}

void _onUserRemoved(Event event) {
  db.deleteUser(event.snapshot.value[_uuid]);
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

// ####################################################################################################
// User
Future<bool> addUser(User user) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_User);

    var result = await _ref.child("${user.uuid}").runTransaction((data) async {
      data.value = _UserToMap(user);

      return data;
    });

    return result.committed;
  });
}

Future<bool> updateUser(User user) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_User);

    await _ref.child("${user.uuid}").update(_UserToMap(user));

    return true;
  });
}

Future<bool> deleteUser(User user) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_User);

    await _ref.child("${user.uuid}").remove();

    return true;
  });
}

Future<User> getCurrentUser() async {
  User _user;
  try {
    FirebaseUser user = await _auth.currentUser();

    if (user != null) {
      var photoUrlList = user.providerData != null && user.providerData.isNotEmpty
          ? user.providerData.where((f) => f.photoUrl != null && f.photoUrl.isNotEmpty).map((f) => f.photoUrl).toList()
          : [];

      _user = User(
        user.uid,
        user.email,
        user.displayName,
        photoUrlList != null && photoUrlList.isNotEmpty ? photoUrlList[0] : null
      );
    }
  } catch (e) {
    print("Error: ${e.toString()}");
  }

  return _user;
}

Future<User> login(String email, String password) async {
  FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);

  if (user != null) {
    return User(user.uid, user.email, user.displayName, user.photoUrl);
  }

  throw Exception("Failed to signin to firebase");
}

Future<bool> checkCurrentUser() async {
  return await _auth.currentUser() != null;
}

Future<bool> registerEmail(String email, String password) async {
  FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: email, password: password);

  return user != null;
}

Future<bool> updateDisplayName(String displayName) async {
  FirebaseUser user = await _auth.currentUser();

  if(user == null) throw Exception("No user available");

  UserUpdateInfo userUpdateInfo = UserUpdateInfo();
  userUpdateInfo.displayName = displayName;
  await user.updateProfile(userUpdateInfo);

  return true;
}

Future<bool> signOut() async {
  await _auth.signOut();

  return true;
}