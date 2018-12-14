import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase/authentication.dart' as fm;
import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/shared_pref/shared_preference.dart';

class LeftDrawerRepository extends CleanArchitectureRepository {
  Future<bool> signOut() async {
    bool result = await fm.signOut();

    if(result) {
      // clear preference
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove(UserUUID);
      pref.remove(prefHomeProfile);

      // delete database
      db.deleteDatabase();
      fdb.removeRefenrence();
    }

    return result;
  }
}