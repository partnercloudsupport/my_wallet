import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fb;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

export 'package:my_wallet/ui/category/list/data/list_category_entity.dart';
import 'package:my_wallet/utils.dart' as Utils;

class CategoryListRepository extends CleanArchitectureRepository{

  final _CategoryListDatabaseRepository _dbRepo = _CategoryListDatabaseRepository();
  final _CategoryListFirebaseRepository _fbRepo = _CategoryListFirebaseRepository();

  Future<List<AppCategory>> loadCategories() {
    return _dbRepo.loadCategories();
  }

  Future<Budget> findBudget(int catid, DateTime start, DateTime end) {
    return _dbRepo.findBudget(catid, start, end);
  }

  Future<AppCategory> loadCategory(int id) {
    return _dbRepo.loadCategory(id);
  }

  Future<bool> deleteCategory(AppCategory cat) {
    _fbRepo.deleteCategory(cat);

    return _dbRepo.deleteCategory(cat);
  }

  Future<List<Budget>> findAllBudgets(int catId) {
    return _dbRepo.findAllBudgets(catId);
  }

  Future<void> deleteAllBudgets(List<Budget> budgets) {
    _fbRepo.deleteAllBudgets(budgets);

    return _dbRepo.deleteAllBudgets(budgets);
  }

  Future<List<AppTransaction>> findAllTransaction(int catId) {
    return _dbRepo.findAllTransaction(catId);
  }

  Future<void> deleteAllTransactions(List<AppTransaction> transactions) {
    _fbRepo.deleteAllTransactions(transactions);

    return _dbRepo.deleteAllTransactions(transactions);
  }

  Future<double> sumSpentPerMonthByCategory(int catId, DateTime month) {
    return _dbRepo.sumSpentPerMonthByCategory(catId, month);
  }
}

class _CategoryListDatabaseRepository {
  Future<List<AppCategory>> loadCategories() async {
      return await db.queryCategory();
  }

  Future<AppCategory> loadCategory(int id) async {
    var list = await db.queryCategory(id: id);

    return list == null || list.isEmpty ? null : list[0];
  }

  Future<Budget> findBudget(int catid, DateTime start, DateTime end) {
    return db.findBudget(catId: catid, start: start, end: end);
  }

  Future<List<Budget>> findAllBudgets(int catId) {
    return db.findAllBudgetForCategory(catId);
  }

  Future<List<AppTransaction>> findAllTransaction(int catId) {
    return db.queryAllTransactionForCategory(catId);
  }

  Future<bool> deleteCategory(AppCategory cat) async {
    return (await db.deleteCategory(cat.id)) >= 0;
  }

  Future<void> deleteAllBudgets(List<Budget> budgets) async {
    return db.deleteBudgets(budgets.map((f) => f.id).toList());
  }

  Future<void> deleteAllTransactions(List<AppTransaction> transactions) {
    return db.deleteTransactions(transactions.map((f) => f.id).toList());
  }

  Future<double> sumSpentPerMonthByCategory(int catId, DateTime month) {
    return db.sumTransactionsByCategory(catId: catId, type: TransactionType.typeExpense, start: Utils.firstMomentOfMonth(month), end: Utils.lastDayOfMonth(month));
  }
}

class _CategoryListFirebaseRepository {
  Future<bool> deleteCategory(AppCategory cat) {
    return fb.deleteCategory(cat);
  }

  Future<void> deleteAllBudgets(List<Budget> budgets) async {
    if(budgets != null && budgets.isNotEmpty) {
      for(Budget budget in budgets) {
        await fb.deleteBudget(budget.id);
      }
    }
  }

  Future<void> deleteAllTransactions(List<AppTransaction> transactions) async {
    if(transactions != null && transactions.isNotEmpty) {
      for(AppTransaction trans in transactions) {
        await fb.deleteTransaction(trans);
      }
    }
  }
}