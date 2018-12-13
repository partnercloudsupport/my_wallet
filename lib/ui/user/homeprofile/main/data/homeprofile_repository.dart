import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/firebase_manager.dart' as _fm;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ui/user/homeprofile/main/data/homeprofile_entity.dart';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/user/homeprofile/main/data/homeprofile_exception.dart';
export 'package:my_wallet/ui/user/homeprofile/main/data/homeprofile_entity.dart';

class HomeProfileRepository extends CleanArchitectureRepository {
  final _HomeProfileDataBaseRepository _fbRepo = _HomeProfileDataBaseRepository();

  Future<User> getCurrentUser() {
    return _fbRepo.getCurrentUser();
  }

  Future<HomeEntity> searchUserHome(User user) {
    return _fbRepo.searchUserHome(user);
  }
}

class _HomeProfileDataBaseRepository {
  Future<User> getCurrentUser() {
    return _fm.getCurrentUser();
  }

  Future<HomeEntity> searchUserHome(User user) async {
    Home home = await _fm.searchUserHome(user);

    return home == null ? null : HomeEntity(home.key, home.host, home.name);
  }
}