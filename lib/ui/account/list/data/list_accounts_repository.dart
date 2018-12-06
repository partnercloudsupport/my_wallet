import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/database/firebase_manager.dart' as fb;
import 'package:my_wallet/ca/data/ca_repository.dart';

class ListAccountsRepository extends CleanArchitectureRepository {
  final _ListAccountsDatabaseRepository _dbRepo = _ListAccountsDatabaseRepository();
  final _ListAccountsFirebaseRepository _fbRepo = _ListAccountsFirebaseRepository();

  Future<List<Account>> loadAllAccounts() {
    return _dbRepo.loadAllAccounts();
  }

  Future<bool> deleteAccount(Account acc) {
    return _fbRepo.deleteAccount(acc);
  }
}

class _ListAccountsDatabaseRepository {
  Future<List<Account>> loadAllAccounts() async {
    return await db.queryAccounts();
  }
}

class _ListAccountsFirebaseRepository {
  Future<bool> deleteAccount(Account acc) async {
    return await fb.deleteAccount(acc);
  }
}