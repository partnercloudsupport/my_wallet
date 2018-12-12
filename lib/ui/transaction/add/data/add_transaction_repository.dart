import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/data/firebase_manager.dart' as _fm;
import 'package:my_wallet/ui/transaction/add/domain/add_transaction_exception.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';
class AddTransactionRepository extends CleanArchitectureRepository {

  final _AddTransactionDatabaseRepository _dbRepo = _AddTransactionDatabaseRepository();
  final _AddTransactionFirebaseRepository _fbRepo = _AddTransactionFirebaseRepository();

  Future<List<Account>> loadAccounts() {
    return _dbRepo.loadAccounts();
  }

  Future<List<AppCategory>> loadCategory() {
    return _dbRepo.loadCategory();
  }

  Future<TransactionDetail> loadTransactionDetail(int id) {
    return _dbRepo.loadTransactionDetail(id);
  }

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
      TransactionDetail currentTransaction,
      Account acc,
      TransactionType type,
      double amount) {
    return _fbRepo.updateAccount(currentTransaction, acc, type, amount);
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

  Future<List<Account>> loadAccounts() async{
    return _db.queryAccounts();
  }

  Future<List<AppCategory>> loadCategory() {
    return _db.queryCategory();
  }

  Future<TransactionDetail> loadTransactionDetail(int id) async {
    List<AppTransaction> transactions = await _db.queryTransactions(id: id);

    if(transactions == null || transactions.isEmpty) throw AddTransactionException("Transaction with id $id not found");

    AppTransaction transaction = transactions[0];

    List<Account> accounts = await _db.queryAccounts(id: transaction.accountId);

    Account account;
    if(accounts != null && accounts.isNotEmpty) account = accounts[0];

    List<AppCategory> categories = await _db.queryCategory(id: transaction.categoryId);

    AppCategory category;
    if(categories != null && categories.isNotEmpty) category = categories[0];

    return TransactionDetail(
      transaction.id,
      transaction.dateTime,
      account,
      category,
      transaction.amount,
      transaction.type
    );
  }

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
    return _db.generateTransactionId();
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
      String _desc) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();

    var uuid = sharedPref.getString(UserUUID);

    return await _fm.addTransaction(AppTransaction(id, _date, _account.id, _category.id, _amount, _desc, _type, uuid));
  }

  Future<bool> updateAccount(
      TransactionDetail currentTransaction,
      Account acc,
      TransactionType type,
      double amount) {
    var revertBalance = 0.0;

    if(currentTransaction != null) {
      // revert to amount before this transaction happened
      revertBalance = (TransactionType.isExpense(currentTransaction.type) ? 1 : -1) * currentTransaction.amount;
    }

    var newBalance = acc.balance + (TransactionType.isExpense(type) ? -1 : 1) * amount + revertBalance;

    return _fm.updateAccount(Account(acc.id, acc.name, newBalance, acc.type, acc.currency));
  }
}