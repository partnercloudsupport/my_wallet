import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ui/user/homeprofile/data/homeprofile_exception.dart';
import 'package:my_wallet/data/firebase_manager.dart' as _fm;
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:flutter/services.dart';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/user/homeprofile/data/homeprofile_exception.dart';

class HomeProfileRepository extends CleanArchitectureRepository {
  final _HomeProfileFirebaseRepository _fbRepo = _HomeProfileFirebaseRepository();

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

class _HomeProfileFirebaseRepository {
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
      throw HomeProfileException(e.message);
    } catch (e) {
      throw HomeProfileException(e.toString());
    }

    return host.uuid;
  }
}