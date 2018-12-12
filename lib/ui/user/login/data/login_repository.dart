import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase_manager.dart' as fm;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:my_wallet/data/data.dart';

class LoginRepository extends CleanArchitectureRepository{
  final _LoginFirebaseRepository _fbRepo = _LoginFirebaseRepository();

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

  Future<void> saveUserToDatabase(User user) {
    return _fbRepo._saveUserToDatabase(user);
  }

  Future<void> saveUserReference(String uuid) async {
    var sharePref = await SharedPreferences.getInstance();

    await sharePref.setString(UserUUID, uuid);
  }
}

class _LoginFirebaseRepository {
  Future<void> signInToFirebase(email, password) {
    return fm.login(email, password);
  }

  Future<void> _saveUserToDatabase(User user) {
    return fm.addUser(user);
  }
}
