import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/transaction/add/domain/add_transaction_exception.dart';
import 'package:my_wallet/database/firebase_manager.dart' as fm;

class AddTransactionRepository {
  final _AddTransactionDatabaseRepository _dbRepo = _AddTransactionDatabaseRepository();
  final _AddTransactionFirebaseRepository _fbRepo = _AddTransactionFirebaseRepository();

  Future<int> generateId() {
    return _dbRepo.generateId();
  }

  Future<bool> saveTransaction(
      int id,
      TransactionType _type,
      Account _account,
      AppCategory _category,
      double _amount,
      DateTime _date,
      String _desc) {
    return _fbRepo.saveTransaction(id, _type, _account, _category, _amount, _date, _desc);
  }

  Future<bool> updateAccount(
      Account acc,
      TransactionType type,
      double amount) {
    return _fbRepo.updateAccount(acc, type, amount);
  }

  Future<bool> checkTransactionType(TransactionType type) {
    return _dbRepo.checkTransactionType(type);
  }

  Future<bool> checkAccount(Account acc) {
    return _dbRepo.checkAccount(acc);
  }

  Future<bool> checkCategory(AppCategory cat) {
    return _dbRepo.checkCategory(cat);
  }

  Future<bool> checkDateTime(DateTime datetime) {
    return _dbRepo.checkDateTime(datetime);
  }

  Future<bool> checkDescription(String desc) {
    return _dbRepo.checkDescription(desc);
  }
}

class _AddTransactionDatabaseRepository {

  Future<bool> checkTransactionType(TransactionType type) async {
    return type == null ? throw AddTransactionException("Please Select Transaction Type") : true;
  }

  Future<bool> checkAccount(Account acc) async {
    return acc == null ? throw AddTransactionException("Please select an Account") : true;
  }

  Future<bool> checkCategory(AppCategory cat) async {
    return cat == null ? throw AddTransactionException("Please select a Category") : true;
  }

  Future<bool> checkDateTime(DateTime datetime) async {
    return datetime == null ? throw AddTransactionException("Please select a Date") : true;
  }

  Future<bool> checkDescription(String desc) async {
    return desc == null || desc.isEmpty ? throw AddTransactionException("Please add a description for this transaction") : true;
  }

  Future<int> generateId() {
    return db.generateTransactionId();
  }
}

class _AddTransactionFirebaseRepository {
  Future<bool> saveTransaction(
      int id,
      TransactionType _type,
      Account _account,
      AppCategory _category,
      double _amount,
      DateTime _date,
      String _desc) {
    return fm.addTransaction(AppTransaction(id, _date, _account.id, _category.id, _amount, _desc, _type));
  }

  Future<bool> updateAccount(
      Account acc,
      TransactionType type,
      double amount) {
    var newBalance = acc.balance + (TransactionType.typeExpense.contains(type) ? -1 : 1) * amount;

    return fm.updateAccount(Account(acc.id, acc.name, newBalance, acc.type, acc.currency));
  }
}