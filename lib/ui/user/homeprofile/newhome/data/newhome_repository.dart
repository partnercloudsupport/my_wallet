import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:flutter/services.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/firebase_manager.dart' as _fm;
import 'package:my_wallet/data/database_manager.dart' as _db;

import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:my_wallet/ui/user/homeprofile/newhome/data/newhome_exception.dart';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/user/homeprofile/newhome/data/newhome_exception.dart';

class NewHomeRepository extends CleanArchitectureRepository {
  final _NewHomeFirebaseRepository _fbRepo = _NewHomeFirebaseRepository();

  Future<User> getCurrentUser() {
    return _fbRepo.getCurrentUser();
  }

  Future<String> createHome(User host, String name) {
    return _fbRepo.createHome(host, name);
  }

  Future<void> saveKey(String homeKey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString(prefHomeProfile, homeKey);
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
}