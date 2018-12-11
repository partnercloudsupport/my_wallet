import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/database/firebase_manager.dart' as fm;
import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/utils.dart' as Utils;

export 'package:my_wallet/database/data.dart';

class LoginRepository extends CleanArchitectureRepository{
  final _LoginFirebaseRepository _fbRepo = _LoginFirebaseRepository();
  final _LoginDatabaseRepository _dbRepo = _LoginDatabaseRepository();

  Future<void> validateEmail(String email) async {
    if (email == null || email.isEmpty) throw Exception("Email is empty");
    if(!Utils.isEmailFormat(email)) throw Exception("Invalid email format");
  }

  Future<void> validatePassword(String password) async {
    if(password == null || password.isEmpty) throw Exception("Password is empty");
    if(password.length < 6) throw Exception("Password is too short");
  }

  Future<User> signinToFirebase(String email, String password) {
    return _fbRepo.signInToFirebase(email, password);
  }

//  Future<void> saveUserToDatabase(User user) {
//    _dbRepo._saveUserToDatabase(user);
//  }
}

class _LoginFirebaseRepository {
  Future<void> signInToFirebase(email, password) {
    return fm.login(email, password);
  }
}

class _LoginDatabaseRepository {
//  Future<void> _saveUserToDatabase(User user) {
//    db.saveUser(user)
//  }
}