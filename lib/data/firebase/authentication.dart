import 'package:my_wallet/data/firebase/common.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:my_wallet/data/data.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const _members = "members";
const _homes = "homes";
const _host = "host";
const _key = "key";
const _data = "data";

FirebaseAuth _auth;
bool _isInit = false;
final Lock _lock = Lock();

Firestore _firestore;


Future<void> init(FirebaseApp app) async {
  return _lock.synchronized(() async {
    if(_isInit) return;

    _isInit = true;

    _auth = FirebaseAuth.fromApp(app);

    _firestore = await firestore(app);
  });
}

/// after login, this user does not contain color
Future<User> login(String email, String password) async {
  return _lock.synchronized(() async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);

    if (user != null) {
      return User(user.uid, user.email, user.displayName, user.photoUrl, null);
    }

    throw Exception("Failed to signin to firebase");
  });
}

Future<User> signInWithGoogle() async {
  return _lock.synchronized(() async {
    GoogleSignIn _signin = GoogleSignIn();
    GoogleSignInAccount _account = await _signin.signIn();
    GoogleSignInAuthentication _authentication = await _account.authentication;
    
    FirebaseUser _user = await _auth.signInWithGoogle(idToken: _authentication.idToken, accessToken: _authentication.accessToken);

    if(_user != null) {
      print(await _auth.currentUser());
      return User(_user.uid, _user.email, _user.displayName, _user.photoUrl, null);
    }

    throw Exception("Failed to signin with Google");
  });
}

Future<User> signInWithFacebook() async {
  return _lock.synchronized(() async {
    FacebookLogin _login = FacebookLogin();
    FacebookLoginResult _result = await _login.logInWithReadPermissions(['email']);

    if(_result.status == FacebookLoginStatus.loggedIn) {
      var graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${_result.accessToken.token}');

      var profile = json.decode(graphResponse.body);
      print(profile.toString());

      var displayName = profile['name'];
      print("Name: ${profile['name']}");

      FirebaseUser _user = await _auth.signInWithFacebook(accessToken: _result.accessToken.token);

      if (_user != null) {
        UserUpdateInfo userUpdateInfo = UserUpdateInfo();
        userUpdateInfo.displayName = displayName;
        await _user.updateProfile(userUpdateInfo);

        return User(_user.uid, _user.email, _user.displayName, _user.photoUrl, null);
      }
    }

    throw Exception("Failed to signin with Facebook");
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
    DocumentSnapshot snapshot;
  try {
    snapshot = await _firestore.collection(_data).document(homeKey).collection(tblUser).document(user.uuid).get();
  } catch(e) {
    throw Exception("User not found");
  }

    if (snapshot == null) throw Exception("User not found");

    return _snapshotToUser(snapshot);
  });
}

Future<bool> joinHome(Home home, User user) async  {
  return _lock.synchronized(() async {
    CollectionReference _ref = _firestore.collection(_homes).document(home.key).collection(_members);

    QuerySnapshot members = await _ref.getDocuments();

    int id = members == null || members.documents == null ? 0 : members.documents.length;

    await _ref.document("$id").setData({fldEmail : user.email});
    return true;
  });
}

Future<Home> findHomeOfHost(String host) async {
  return _lock.synchronized(() async {
    QuerySnapshot _allHomes = await _firestore.collection(_homes).getDocuments();

    Home home;

    do {
      if(_allHomes == null) break;

      if(_allHomes.documents == null) break;

      if(_allHomes.documents.isEmpty) break;

      var _hostHome = _allHomes.documents.firstWhere((f) => f.data[_host] == host);
      if(_hostHome != null) {
        home = Home(_hostHome.documentID, _hostHome.data[_host], _hostHome.data[fldName]);
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
    CollectionReference _ref = _firestore.collection(_homes);

    await _ref.document(homeKey).setData({
      _host: hostEmail,
      fldName: homeName
    });

    return true;
  });
}

Future<bool> isHost(User user) {
  return _lock.synchronized(() async {
    QuerySnapshot snapshot = await _firestore.collection(_homes).where(_host, isEqualTo: user.email).getDocuments();
    return snapshot.documents != null && snapshot.documents.isNotEmpty;
  });
}

Future<Home> searchUserHome(User user) {
  return _lock.synchronized(() async {
    Home home;
    do {
    QuerySnapshot _snapshot = await _firestore.collection(_homes).getDocuments();
    if(_snapshot == null || _snapshot.documents == null || _snapshot.documents.isEmpty) break;

    // check each document in this snapshot
    for (DocumentSnapshot f in _snapshot.documents) {
      List<DocumentSnapshot> _memSnapshot = (await f.reference.collection(_members).where(fldEmail, isEqualTo: user.email).getDocuments()).documents;

      if(_memSnapshot != null && _memSnapshot.isNotEmpty) {
        home = Home(f.documentID, f.data[_host], f.data[fldName]);

        break;
      }
    }
    } while (false);

    return home;
  });
}


User _snapshotToUser(DocumentSnapshot snapshot) {
  return User(snapshot.documentID, snapshot.data[fldEmail], snapshot.data[fldDisplayName], snapshot.data[fldPhotoUrl], snapshot.data[fldColor]);
}