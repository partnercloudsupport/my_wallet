import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:flutter/services.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/firebase/authentication.dart' as _fm;
import 'package:my_wallet/data/firebase/database.dart' as _fdb;

import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:my_wallet/ui/user/homeprofile/newhome/data/newhome_exception.dart';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/user/homeprofile/newhome/data/newhome_exception.dart';

import 'dart:math';

class NewHomeRepository extends CleanArchitectureRepository {
  final _NewHomeFirebaseRepository _fbRepo = _NewHomeFirebaseRepository();

  Future<User> getCurrentUser() {
    return _fbRepo.getCurrentUser();
  }

  /// create new home
  Future<String> createHome(User host, String name) {
    return _fbRepo.createHome(host, name);
  }

  /// join a home
  Future<Home> findHomeOfHost(String host) {
    return _fbRepo.findHomeOfHost(host);
  }

  Future<bool> joinHome(Home home, User user) {
    return _fbRepo.joinHome(home, user);
  }

  Future<void> saveKey(String homeKey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString(prefHomeProfile, homeKey);
  }

  Future<void> updateDatabaseReference(String key) {
    return _fbRepo.updateDatabaseReference(key);
  }

  Future<void> saveUserToHome(User user) {
    return _fbRepo.saveUserToHome(user);
  }
}

class _NewHomeFirebaseRepository {
  Future<User> getCurrentUser() {
    return _fm.getCurrentUser();
  }

  Future<String> createHome(User host, String name) async {
    try {
      await _fm.createHome(
          host.email,
          host.uuid,
          name
      );
    } on PlatformException catch (e) {
      throw NewHomeException(e.message);
    } catch (e) {
      throw NewHomeException(e.toString());
    }

    return host.uuid;
  }

  Future<Home> findHomeOfHost(String host) async {
    try {
      return await _fm.findHomeOfHost(host);
    } on PlatformException catch (e) {
      throw NewHomeException(e.message);
    } catch (e) {
      throw NewHomeException(e.toString());
    }
  }

  Future<bool> joinHome(Home home, User user) async {
    try {
      return await _fm.joinHome(home, user);
    } on PlatformException catch(e) {
      throw NewHomeException(e.message);
    } catch (e) {
      throw NewHomeException(e.toString());
    }
  }

  Future<void> updateDatabaseReference(String homeKey) {
    return _fdb.setupDatabase(homeKey);
  }

  Future<void> saveUserToHome(User user) {
    Random random = Random();
    return _fdb.addUser(user, color: random.nextInt(0xFFEEEEEE));
  }
}