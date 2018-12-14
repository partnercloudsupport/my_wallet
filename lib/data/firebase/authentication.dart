import 'package:my_wallet/data/firebase/common.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:my_wallet/data/data.dart';

const _members = "members";
const _homes = "homes";
const _host = "host";
const _key = "key";
const _data = "data";

FirebaseAuth _auth;
bool _isInit = false;
final Lock _lock = Lock();

DatabaseReference _database;


Future<void> init(FirebaseApp app) async {
  return _lock.synchronized(() async {
    if(_isInit) return;

    _isInit = true;

    _auth = FirebaseAuth.fromApp(app);

    _database = FirebaseDatabase(app: app).reference();
  });
}

Future<User> login(String email, String password) async {
  return _lock.synchronized(() async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);

    if (user != null) {
      print("user display name ${user.displayName}");
      DatabaseReference _ref = _database.reference().child(tblUser);

      var colorSnapshot = await _ref.child(tblUser).child(user.uid).child(fldColor).once();
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

/// This method will return User data with only 4 info: uid, email, and displayName , and also photoUrl (if available)
/// Color for this user is null. To get user with color, use database.getUserDetail(<homeKey>)
Future<User> getCurrentUser() async {
  return _lock.synchronized(() async {
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
            photoUrlList != null && photoUrlList.isNotEmpty ? photoUrlList[0] : null,
            null
        );
      }
    } on PlatformException catch (e) {
      print("Error: ${e.toString()}");
    }

    return _user;
  });
}

/// This method will try to access user's home table to get user detail from /data/<homekey>/User
Future<User> getUserDetail(String homeKey, User user) async {
  return _lock.synchronized(() async {
    DataSnapshot snapshot = await _database.reference().child(_data).child(homeKey).child(tblUser).child(user.uuid).once();

    if(snapshot == null) throw Exception("User not found");

    return snapshotToUser(snapshot);
  });
}

Future<bool> joinHome(Home home, User user) async  {
  return _lock.synchronized(() async {
    DatabaseReference _ref = _database.reference().child(_homes).child(home.key).child(_members);

    DataSnapshot members = await _ref.once();

    int id = members == null || members.value == null ? 0 : members.value.length;

    var result = await _ref.child("$id").runTransaction((data) async {
      data.value = {
        fldEmail : user.email
      };

      return data;
    });
    return result.committed;
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
          home = Home(key, value[_host], value[fldName]);

          break;
        }
      }

    } while (false);

    return home;

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
        fldName: homeName,
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

          Iterable found = list.where((f) => f[fldEmail] == user.email);

          if(found.length >= 1) {
            home = Home(key, value[_host], value[fldName]);

            break;
          }
        }
      }

    } while (false);

    return home;
  });
}

