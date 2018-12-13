import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase_manager.dart' as fm;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/ui/user/login/data/login_exception.dart';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/user/login/data/login_exception.dart';

class LoginRepository extends CleanArchitectureRepository{
  final _LoginFirebaseRepository _fbRepo = _LoginFirebaseRepository();

  Future<void> validateEmail(String email) async {
    if (email == null || email.isEmpty) throw LoginException("Email is empty");
    if(!Utils.isEmailFormat(email)) throw LoginException("Invalid email format");
  }

  Future<void> validatePassword(String password) async {
    if(password == null || password.isEmpty) throw LoginException("Password is empty");
    if(password.length < 6) throw LoginException("Password is too short");
  }

  Future<User> signinToFirebase(String email, String password) {
    return _fbRepo.signInToFirebase(email, password);
  }

  Future<bool> checkHost(User user) {
    return _fbRepo.checkHost(user);
  }

  Future<void> saveHome(String homeKey) async {
    var sharePref = await SharedPreferences.getInstance();

    await sharePref.setString(prefHomeProfile, homeKey);
  }

  Future<void> saveUserReference(String uuid) async {
    var sharePref = await SharedPreferences.getInstance();

    await sharePref.setString(UserUUID, uuid);
  }

  Future<void> switchReference() {
    return _fbRepo.switchReference();
  }

  Future<bool> checkUserHome() async {
    var sharePref = await SharedPreferences.getInstance();

    var key = sharePref.getString(prefHomeProfile);

    return key != null && key.isNotEmpty;
  }
}

class _LoginFirebaseRepository {
  Future<void> signInToFirebase(email, password) {
    return fm.login(email, password);
  }

  Future<bool> checkHost(User user) {
    return fm.isHost(user);
  }

  Future<void> switchReference() {
    return fm.setupDatabase();
  }
}
