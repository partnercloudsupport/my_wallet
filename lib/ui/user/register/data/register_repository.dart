import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/user/register/domain/register_exception.dart';

import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/firebase/authentication.dart' as fm;

import 'package:flutter/services.dart';
import 'package:my_wallet/utils.dart' as Utils;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

class RegisterRepository extends CleanArchitectureRepository {
  _RegisterFirebaseRepository _fbRepo = _RegisterFirebaseRepository();

  Future<bool> validateDisplayName(String name) {
    return _fbRepo.validateDisplayName(name);
  }

  Future<bool> validateEmail(String email) {
    return _fbRepo.validateEmail(email);
  }

  Future<bool> validatePassword(String password) {
    return _fbRepo.validatePassword(password);
  }

  Future<bool> registerEmail(String email, String password, String displayName) {
    return _fbRepo.registerEmail(email, password, displayName);
  }

//  Future<bool> updateDisplayName(String displayName)  {
//    return _fbRepo.updateDisplayName(displayName);
//  }

  Future<User> getCurrentUser() {
    return _fbRepo.getCurrentUser();
  }

  Future<void> saveUserReference(String uuid) async {
    return _fbRepo.saveUserReference(uuid);
  }
}

class _RegisterFirebaseRepository {
  Future<bool> validateDisplayName(String name) async {
    return name == null || name.isEmpty ? throw RegisterException("Name must not be empty") : true;
  }

  Future<bool> validateEmail(String email) async {
    if (email == null || email.isEmpty) throw RegisterException("Email must not empty");
    if(!Utils.isEmailFormat(email)) throw RegisterException("Invalid Email format");

    return true;
  }

  Future<bool> validatePassword(String password) async {
    if(password == null || password.isEmpty) throw RegisterException("Password is empty");
    if(password.length < 6) throw RegisterException("Password is too short");

    return true;
  }

  Future<bool> registerEmail(String email, String password, String displayName) async {
    try {
      await fm.registerEmail(email, password, displayName: displayName);
    } on PlatformException catch (e) {
      print("${e.code} :: ${e.message} :: ${e.toString()}");
      throw RegisterException(e.message);
    } catch (e) {
      throw RegisterException(e.toString());
    }

    return true;
  }

//  Future<bool> updateDisplayName(String displayName) async {
//    try {
//      await fm.updateDisplayName(displayName);
//    } on PlatformException catch (e) {
//      throw RegisterException(e.message);
//    } catch (e) {
//      throw RegisterException(e.toString());
//    }
//
//    return true;
//  }

  Future<User> getCurrentUser() {
    return fm.getCurrentUser();
  }

  Future<void> saveUserReference(String uuid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.setString(UserUUID, uuid);
  }
}
