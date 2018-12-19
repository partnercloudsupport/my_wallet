import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/firebase/database.dart' as fm;
import 'package:my_wallet/shared_pref/shared_preference.dart';

class GoHomeRepository extends CleanArchitectureRepository {
  Future<void> updateHomeReference(String homeKey, String homeName, String hostEmail) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString(prefHomeProfile, homeKey);
    pref.setString(prefHomeName, homeName);
    pref.setString(prefHostEmail, hostEmail);
  }

  Future<void> switchReference(String homeKey) async {
    return fm.setupDatabase(homeKey);
  }
}