import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fb;
import 'package:my_wallet/ca/data/ca_repository.dart';

class ListAccountsRepository extends CleanArchitectureRepository {
  final _ListAccountsDatabaseRepository _dbRepo = _ListAccountsDatabaseRepository();
  final _ListAccountsFirebaseRepository _fbRepo = _ListAccountsFirebaseRepository();

  Future<List<Account>> loadAllAccounts() {
    return _dbRepo.loadAllAccounts();
  }

  Future<bool> deleteAccount(Account acc) {
    _fbRepo.deleteAccount(acc);

    return _dbRepo.deleteAccount(acc);
  }

  Future<List<AppTransaction>> loadAllTransaction(int accountId) {
    return _dbRepo.loadAllTransaction(accountId);
  }

  Future<void> deleteTransaction(AppTransaction transaction) {
    _fbRepo.deleteTransaction(transaction);

    return _dbRepo.deleteTransaction(transaction);
  }
}

class _ListAccountsDatabaseRepository {
  Future<List<Account>> loadAllAccounts() async {
    return await db.queryAccounts();
  }

  Future<List<AppTransaction>> loadAllTransaction(int accountId) {
    return db.queryAllTransactionForAccount(accountId);
  }

  Future<bool> deleteAccount(Account acc) async {
    return (await db.deleteAccount(acc.id)) >= 0;
  }

  Future<void> deleteTransaction(AppTransaction transaction) {
    return db.deleteTransaction(transaction.id);
  }
}

class _ListAccountsFirebaseRepository {
  Future<bool> deleteAccount(Account acc) async {
    return await fb.deleteAccount(acc);
  }

  Future<void> deleteTransaction(AppTransaction transaction) {
    return fb.deleteTransaction(transaction);
  }
}