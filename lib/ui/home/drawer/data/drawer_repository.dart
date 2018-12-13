import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase_manager.dart' as fm;
import 'package:my_wallet/shared_pref/shared_preference.dart';

class LeftDrawerRepository extends CleanArchitectureRepository {
  Future<bool> signOut() async {
    bool result = await fm.signOut();

    if(result) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove(UserUUID);
      pref.remove(prefHomeProfile);
    }

    return result;
  }
}