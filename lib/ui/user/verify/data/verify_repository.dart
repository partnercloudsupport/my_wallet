import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/firebase/authentication.dart' as auth;
import 'package:my_wallet/data/firebase/authentication.dart' as fm;
import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/data/database_manager.dart' as db;

import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

class RequestValidationRepository extends CleanArchitectureRepository {
  RequestValidationDatabaseRepository _dbRepo = RequestValidationDatabaseRepository();
  RequestValidationFirebaseRepository _fbRepo = RequestValidationFirebaseRepository();

  Future<bool> requestValidationEmail() {
    return _fbRepo.requestValidationEmail();
  }

  Future<bool> signOut() {
    return _fbRepo.signOut();
  }

  Future<void> clearAllPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.remove(UserUUID);
    await pref.remove(prefHomeProfile);
  }

  Future<void> deleteDatabase() {
    return _dbRepo.deleteDatabase();
  }

  Future<void> unlinkFbDatabase() {
    return _fbRepo.unlinkFbDatabase();
  }

  Future<User> currentUser() {
    return _fbRepo.currentUser();
  }
}

class RequestValidationDatabaseRepository {
  Future<void> deleteDatabase() {
    return db.dropAllTables();
  }
}

class RequestValidationFirebaseRepository {
  Future<bool> requestValidationEmail() {
    return auth.sendValidationEmail();
  }

  Future<bool> signOut() {
    return fm.signOut();
  }

  Future<void> unlinkFbDatabase() async {
    return fdb.removeReference();
  }

  Future<User> currentUser() {
    return fm.getCurrentUser();
  }
}