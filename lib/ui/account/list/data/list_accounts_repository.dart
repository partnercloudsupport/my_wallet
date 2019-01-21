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

  Future<void> deleteAllTransaction(List<AppTransaction> transactions) {
    _fbRepo.deleteAllTransaction(transactions);

    return _dbRepo.deleteAllTransaction(transactions);
  }

  Future<List<Transfer>> loadAllTransfers(int accountId) {
    return _dbRepo.loadAllTransfers(accountId);
  }

  Future<void> deleteAllTransfer(List<Transfer> transfer) {
    _fbRepo.deleteAllTransfer(transfer);

    return _dbRepo.deleteAllTransfer(transfer);
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

  Future<void> deleteAllTransaction(List<AppTransaction> transactions) {
    return db.deleteTransactions(transactions.map((f) => f.id).toList());
  }

  Future<List<Transfer>> loadAllTransfers(int accountId) {
    return db.queryTransfer(accountId);
  }

  Future<void> deleteAllTransfer(List<Transfer> transfer) {
    return db.deleteTransfers(transfer.map((f) => f.id).toList());
  }
}

class _ListAccountsFirebaseRepository {
  Future<bool> deleteAccount(Account acc) async {
    return await fb.deleteAccount(acc);
  }

  Future<void> deleteAllTransaction(List<AppTransaction> transaction) {
    return fb.deleteAllTransaction(transaction);
  }

  Future<void> deleteAllTransfer(List<Transfer> transfer) {
    return fb.deleteAllTransfer(transfer);
  }
}