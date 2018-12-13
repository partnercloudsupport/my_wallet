import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:firebase_database/firebase_database.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/firebase_config.dart' as fbConfig;
import 'package:synchronized/synchronized.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

DatabaseReference _database;
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
const _color = "color";
const _host = "host";
const _key = "key";
const _members = "members";
const _homes = "homes";
const _data = "data";

FirebaseApp _app;
Future<FirebaseApp> createFirebaseApp() async {
  if(_app == null )
  _app = await FirebaseApp.configure(
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

  return _app;
}
Future<void> init() async {
  if (_isInit) return;

  _lock.synchronized(() async {
    _auth = FirebaseAuth.fromApp(await createFirebaseApp());
  });

  setupDatabase();

  _isInit = true;
}
Future<void> setupDatabase() async {
  _lock.synchronized(() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String homeKey = pref.getString(prefHomeProfile);

    if(homeKey == null) {
      _database = FirebaseDatabase(app: await createFirebaseApp()).reference();
    } else {
      _database = FirebaseDatabase(app: await createFirebaseApp()).reference().child(_data).child(homeKey);
    }

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
  });
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

Map<String, dynamic> _UserToMap(User user, {int color}) {
  return {_uuid: user.uuid, _email: user.email, _displayName: user.displayName, _photoUrl: user.photoUrl, _color: color != null ? color : user.color};
}

AppCategory _snapshotToCategory(DataSnapshot snapshot) {
  return AppCategory(_toId(snapshot), snapshot.value[_name], snapshot.value[_colorHex], double.parse("${snapshot.value[_balance]}"));
}

Map<String, dynamic> _TransactionToMap(AppTransaction trans) {
  return {_dateTime: trans.dateTime.millisecondsSinceEpoch, _accountId: trans.accountId, _categoryId: trans.categoryId, _amount: trans.amount, _desc: trans.desc, _type: trans.type.id, _uuid: trans.userUid};
}

AppTransaction _snapshotToTransaction(DataSnapshot snapshot) {
  return AppTransaction(_toId(snapshot), DateTime.fromMillisecondsSinceEpoch(snapshot.value[_dateTime]), snapshot.value[_accountId], snapshot.value[_categoryId], double.parse("${snapshot.value[_amount]}"), snapshot.value[_desc], TransactionType.all[snapshot.value[_type]], snapshot.value[_uuid]);
}

User _snapshotToUser(DataSnapshot snapshot) {
  return User(snapshot.value[_uuid], snapshot.value[_email], snapshot.value[_displayName], snapshot.value[_photoUrl], snapshot.value[_color]);
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
Future<bool> addUser(User user, {int color}) async {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_User);

    var result = await _ref.child("${user.uuid}").runTransaction((data) async {
      data.value = _UserToMap(user, color : color);

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
  return _lock.synchronized(() async {
    User _user;

    try {
      FirebaseUser user = await _auth.currentUser();

      if (user != null) {
        var photoUrlList = user.providerData != null && user.providerData.isNotEmpty
            ? user.providerData.where((f) => f.photoUrl != null && f.photoUrl.isNotEmpty).map((f) => f.photoUrl).toList()
            : [];

        DatabaseReference _ref = _database.reference().child(_User);
        var colorSnapshot = await _ref.child(_User).child(user.uid).child(_color).once();

        _user = User(
            user.uid,
            user.email,
            user.displayName,
            photoUrlList != null && photoUrlList.isNotEmpty ? photoUrlList[0] : null,
            colorSnapshot.value == null ? 0 : colorSnapshot.value
        );
      }
    } on Platform catch (e) {
      print("Error: ${e.toString()}");
    }

    return _user;
  });
}

Future<User> login(String email, String password) async {
  return _lock.synchronized(() async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);

    if (user != null) {
      DatabaseReference _ref = _database.reference().child(_User);

      var colorSnapshot = await _ref.child(_User).child(user.uid).child(_color).once();
      var color = colorSnapshot.value;

      return User(user.uid, user.email, user.displayName, user.photoUrl, color);
    }

    throw Exception("Failed to signin to firebase");
  });
}

Future<bool> checkCurrentUser() async {
  return _lock.synchronized(() async => await _auth.currentUser() != null);
}

Future<bool> registerEmail(String email, String password) async {
  return _lock.synchronized(() async => await _auth.createUserWithEmailAndPassword(email: email, password: password) != null);
}

Future<bool> updateDisplayName(String displayName) async {
  return _lock.synchronized(() async {
    FirebaseUser user = await _auth.currentUser();

    if(user == null) throw Exception("No user available");

    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = displayName;
    await user.updateProfile(userUpdateInfo);

    return true;
  });
}

Future<bool> signOut() async {
  return _lock.synchronized(() async {
    await _auth.signOut();

    return true;
  });
}

Future<void> createHome(
    String hostEmail,
    String homeKey,
    String homeName,
) {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_homes);

    var result = await _ref.child("$homeKey").runTransaction((data) async {
      data.value = {
        _host : hostEmail,
        _name: homeName,
      };

      return data;
    });

    return result.committed;
  });
}

Future<bool> isHost(User user) {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_homes);

    DataSnapshot snapshot = await _ref.child(user.uuid).once();

    return snapshot != null && snapshot.value != null;
  });
}

Future<Home> searchUserHome(User user) {
  return _lock.synchronized(() async {
    DataSnapshot _allHomes = await _database.reference().child(_homes).once();

    Home home;
    do {
      if (_allHomes == null) break;

      if (_allHomes.value == null) break;

      if (!(_allHomes.value is Map<dynamic, dynamic>)) break;

      Map map = _allHomes.value as Map<dynamic, dynamic>;

      for (dynamic key in map.keys) {
        dynamic value = map[key];

        if(value[_members] != null && value[_members] is List) {
          List list = value[_members];

          Iterable found = list.where((f) => f[_email] == user.email);

          if(found.length >= 1) {
            home = Home(key, value[_host], value[_name]);

            break;
          }
        }
      }

    } while (false);

    return home;
  });
}

Future<Home> findHomeOfHost(String host) async {
  return _lock.synchronized(() async {
    DataSnapshot _allHomes = await _database.reference().child(_homes).once();

    Home home;
    do {
      if (_allHomes == null) break;

      if (_allHomes.value == null) break;

      if (!(_allHomes.value is Map<dynamic, dynamic>)) break;

      Map map = _allHomes.value as Map<dynamic, dynamic>;

      for (dynamic key in map.keys) {
        dynamic value = map[key];

        if(value[_host] != null && value[_host]== host) {
          home = Home(key, value[_host], value[_name]);

          break;
        }
      }

    } while (false);

    return home;

  });
}

Future<bool> joinHome(Home home, User user) async  {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_homes).child(home.key).child(_members);

    DataSnapshot members = await _ref.once();

    int id = members == null || members.value == null ? 0 : members.value.length;

    var result = await _ref.child("$id").runTransaction((data) async {
      data.value = {
        _email : user.email
      };

      return data;
    });
    return result.committed;
  });
}

Future<User> getUserDetail(String homeKey, User user) {
  return _lock.synchronized(() async {
    DataSnapshot snapshot = await _database.reference().child(_User).child(user.uuid).once();

    if(snapshot == null) throw Exception("User not found");

    return _snapshotToUser(snapshot);
  });
}