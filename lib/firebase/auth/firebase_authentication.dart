import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:my_wallet/firebase/firebase_common.dart';

export 'package:my_wallet/firebase/firebase_common.dart';

import 'package:my_wallet/shared_pref/shared_preference.dart';

class FirebaseAuthentication {
  String apiKey;
  FirebaseApp _app;

  FirebaseAuthentication(FirebaseApp app) {
    this._app = app;

    _init();
  }

  void _init() async {
    apiKey = _app.options.apiKey;
  }

  Future<FirebaseUser> createUserWithEmailAndPassword({@required String email, @required String password, String displayName}) async {
    FirebaseUser user;

    do {
      if (apiKey == null || apiKey.isEmpty) break;

      String url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$apiKey";
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            "scope":"https://www.googleapis.com/auth/datastore"
          },
          body: '{"email":"$email","password":"$password","displayName":"$displayName","returnSecureToken":true}');

      if (response.statusCode != 200) {
        throw _parseError(response);
      }

      var data = json.decode(response.body);

      user = await getUserData(data['idToken']);

      saveRefreshToken(data['refreshToken']);
    } while (false);

    return user;
  }

  Future<FirebaseUser> signInWithEmailAndPassword({@required String email, @required String password}) async {
    FirebaseUser user;
    do {
      if(apiKey == null || apiKey.isEmpty) break;

      String url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$apiKey";
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            "scope":"https://www.googleapis.com/auth/datastore"},
          body: '{"email":"$email","password":"$password","returnSecureToken":true}');

      if(response.statusCode != 200) {
        throw _parseError(response);
      }

      var data = json.decode(response.body);

      user = FirebaseUser._(data);

      saveRefreshToken(data['refreshToken']);

    } while(false);

    return user;
  }

  Future<FirebaseUser> signInWithGoogle({@required String idToken, @required String accessToken}) async {

  }

  Future<FirebaseUser> signInWithFacebook({@required String accessToken}) async {

  }

  Future<FirebaseUser> currentUser() async {
    FirebaseUser user;
    do {
      String refreshToken = await getRefreshToken();

      if(refreshToken == null || refreshToken.isEmpty) break;

      // exchange for idToken
      String token = await _exchangeForIdToken(refreshToken);

      user = await getUserData(token);

    } while (false);

    return user;
  }

  Future<FirebaseUser> getUserData(String token) async {
    FirebaseUser user;
    do {
      var apiKey = (await _app.options).apiKey;

      if (apiKey == null || apiKey.isEmpty) break;

      // get user data to convert it to FirebaseUser object
      var userDataResponse = await post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=$apiKey', headers: {"Content-Type": "application/json"}, body: '{"idToken":"$token}"}');

      if(userDataResponse.statusCode != 200) {
        throw _parseError(userDataResponse);
      }

      var usersData = json.decode(userDataResponse.body);

      var userData = usersData['users'][0];

      user = FirebaseUser._(userData);

    } while (false);

    return user;
  }

  Future<void> signOut() async {
    deleteToken();
  }

  AuthenticationException _parseError(Response response) {
    var error = json.decode(response.body);
    return AuthenticationException(code: response.statusCode, message: error['message'], detailMessage: error['errors'][0]['reason']);
  }

  Future<String> _exchangeForIdToken(String refreshToken) async {
    do {
      if (apiKey == null || apiKey.isEmpty) break;

      String url = "https://securetoken.googleapis.com/v1/token?key=$apiKey";

      Map<String, String> header = {
        "Content-Type" : "application/x-www-form-urlencoded",
      };

      String body= 'grant_type=refresh_token&refresh_token=$refreshToken';

      var response = await post(url, headers: header, body: body);

      if(response.statusCode != 200) {
        throw _parseError(response);
      }

      var data = json.decode(response.body);

      set(data['id_token']);

      return token;
    } while (false);

    return null;
  }
}

class FirebaseUser {
  bool isAnonymous;
  bool isEmailVerified;
  int creationTimestamp;
  int lastSignInTimestamp;
  String providerId;
  String uid;
  String displayName;
  String photoUrl;
  String email;
  String phoneNumber;

  FirebaseUser._(Map<String, dynamic> map) {
    isAnonymous = map['isAnonymous'];
    isEmailVerified = map['isEmailVerified'];
    creationTimestamp = map['creationTimestamp'];
    lastSignInTimestamp = map['lastSignInTimestamp'];
    providerId = map['providerId'];
    uid = map['localId'];
    displayName = map['displayName'];
    photoUrl = map['photoUrl'];
    email = map['email'];
    phoneNumber = map['phoneNumber'];
  }

  Future<FirebaseUser> updateProfile(UserUpdateInfo info) {

  }
}

class UserUpdateInfo {
  String displayName;
}

class AuthenticationException implements Exception {
  final int code;
  final String message;
  final String detailMessage;

  AuthenticationException({this.code = 0, this.message = "Unknown exception", this.detailMessage});

  @override
  String toString() {
    return "Firebase Authentication exception with code $code - $message; Detail message: $detailMessage";
  }
}