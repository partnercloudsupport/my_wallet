import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/user/register/domain/register_exception.dart';
import 'package:my_wallet/database/firebase_manager.dart' as fm;
import 'package:flutter/services.dart';
import 'package:my_wallet/utils.dart' as Utils;

class RegisterRepository extends CleanArchitectureRepository {
  Future<bool> validateDisplayName(String name) async {
    return name == null || name.isEmpty ? throw RegisterException("Name must not be empty") : true;
  }

  Future<bool> validateEmail(String email) async {
    if (email == null || email.isEmpty) throw RegisterException("Email must not empty");
    if(!Utils.isEmailFormat(email)) throw RegisterException("Invalid Email format");

    return true;
  }

  Future<bool> validatePassword(String password) async {
    if(password == null || password.isEmpty) throw Exception("Password is empty");
    if(password.length < 6) throw Exception("Password is too short");

    return true;
  }

  Future<bool> registerEmail(String email, String password) async {
    try {
      await fm.registerEmail(email, password);
    } on PlatformException catch (e) {
      throw RegisterException("${e.code} :: ${e.message} :: ${e.toString()}");
    } catch (e) {
      throw RegisterException(e.toString());
    }

    return true;
  }

  Future<bool> updateDisplayName(String displayName) async {
    try {
      await fm.updateDisplayName(displayName);
    } on PlatformException catch (e) {
      throw RegisterException(e.message);
    } catch (e) {
      throw RegisterException(e.toString());
    }

    return true;
  }
}