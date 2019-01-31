import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/data/firebase/database.dart' as _fm;
import 'package:my_wallet/ui/transaction/add/domain/add_transaction_exception.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

class AddTransactionRepository extends CleanArchitectureRepository {

  final _AddTransactionDatabaseRepository _dbRepo = _AddTransactionDatabaseRepository();
  final _AddTransactionFirebaseRepository _fbRepo = _AddTransactionFirebaseRepository();

  Future<List<Account>> loadAccounts() {
    return _dbRepo.loadAccounts();
  }
  
  Future<Account> loadAccount(int accountId) {
    return _dbRepo.loadAccount(accountId);
  }

  Future<Account> loadLastUsedAccountForCategory(int categoryId) {
    return _dbRepo.loadLastUsedAccountForCategory(categoryId);
  }

  Future<List<AppCategory>> loadCategories(CategoryType type) {
    return _dbRepo.loadCategories(type);
  }

  Future<AppCategory> loadCategory(int categoryId) {
    return _dbRepo.loadCategory(categoryId);
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
      String _desc,
      bool newTransaction) {
    _fbRepo.saveTransaction(id, _type, _account, _category, _amount, _date, _desc);

    return _dbRepo.saveTransaction(id, _type, _account, _category, _amount, _date, _desc, newTransaction);
  }

  Future<bool> deleteTransaction(int id) {
    _fbRepo.deleteTransaction(id);

    return _dbRepo.deleteTransaction(id);
  }

  Future<bool> updateAccount(
      Account acc) {
    _fbRepo.updateAccount(acc);

    return _dbRepo.updateAccount(acc);
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

  Future<UserDetail> loadCurrentUserName() {
    return _dbRepo.loadCurrentUserName();
  }
}

class _AddTransactionDatabaseRepository {

  Future<List<Account>> loadAccounts() async{
    return _db.queryAccounts(type: AccountType.paymentAccount);
  }

  Future<Account> loadAccount(int accountId) async {
    var accounts = await _db.queryAccounts(id: accountId);
    
    return accounts == null || accounts.isEmpty ? null : accounts.first;
  }

  Future<Account> loadLastUsedAccountForCategory(int categoryId) {
    return _db.loadLastUsedAccountForCategory(categoryId: categoryId);
  }

  Future<List<AppCategory>> loadCategories(CategoryType type) {
    return _db.queryCategory(type: type);
  }

  Future<AppCategory> loadCategory(int categoryId) async {
    var categories = await _db.queryCategory(id: categoryId);

    return categories == null || categories.isEmpty ? null : categories.first;
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


    UserDetail user = await _getUserWithUid(transaction.userUid);

    return TransactionDetail(
        transaction.id,
        transaction.dateTime,
        account,
        category,
        transaction.amount,
        transaction.type,
        user,
        transaction.desc
    );
  }

  Future<UserDetail> loadCurrentUserName() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String uid = sharedPref.getString(UserUUID);

    return await _getUserWithUid(uid);
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

  // private helper
  Future<UserDetail> _getUserWithUid(String uid) async {
    List<User> users = await _db.queryUser(uuid: uid);

    User user = users != null && users.isNotEmpty ? users[0] : null;

    var firstName = user.displayName.contains(" ") ? user.displayName.substring(0, user.displayName.indexOf(" ")) : user.displayName;
    firstName = "${firstName.substring(0, 1).toUpperCase()}${firstName.substring(1, firstName.length)}";

    return user == null ? null : UserDetail(user.uuid, firstName);
  }

  Future<bool> saveTransaction(
      int id,
      TransactionType _type,
      Account _account,
      AppCategory _category,
      double _amount,
      DateTime _date,
      String _desc,
      bool newTransaction) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();

    var uuid = sharedPref.getString(UserUUID);

    if(newTransaction) {
      return (await _db.insertTransaction(AppTransaction(
          id,
          _date,
          _account.id,
          _category.id,
          _amount,
          _desc,
          _type,
          uuid))) >= 0;
    } else {
      return (await _db.updateTransaction(AppTransaction(
          id,
          _date,
          _account.id,
          _category.id,
          _amount,
          _desc,
          _type,
          uuid))) >= 0;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    return (await _db.deleteTransaction(id)) >= 0;
  }

  Future<bool> updateAccount(Account acc) async {

    return (await _db.updateAccount(acc)) >= 0;
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

  Future<bool> deleteTransaction(int id) {
    return _fm.deleteTransaction(AppTransaction(id, null, null, null, null, null, null, null));
  }

  Future<bool> updateAccount(Account acc) {
    return _fm.updateAccount(acc);
  }
}
