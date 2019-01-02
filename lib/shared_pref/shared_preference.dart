export 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

const keyTargetSaving = "_keyTargetSaving";

const UserUUID = "_UserUUID";
const prefHomeProfile = "_HomeProfile";
const prefHomeName = "_HomeName";
const prefHostEmail = "_HostEmail";

const _prefIdToken = "prefIdToken";

Future<void> saveRefreshToken(String token) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setString(_prefIdToken, token);
}

Future<String> getRefreshToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString(_prefIdToken);
}

Future<void> deleteToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove(_prefIdToken);
}