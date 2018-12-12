import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

class UserDetailRepository extends CleanArchitectureRepository {
  Future<User> loadCurrentUser() {
    return db.getCurrentUser();
  }
}