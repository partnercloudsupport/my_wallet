import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

class UserDetailRepository extends CleanArchitectureRepository {
  Future<User> loadUserWithUuid(String uuid) async {
    List<User> users =  await db.queryUser(uuid: uuid);

    return users == null || users.isEmpty ? null : users[0];
  }
}