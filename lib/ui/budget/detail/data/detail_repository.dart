import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fd;

import 'package:my_wallet/ui/budget/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/budget/detail/data/detail_entity.dart';

class BudgetDetailRepository extends CleanArchitectureRepository {
  final BudgetDetailDatabaseRepository _dbRepo = BudgetDetailDatabaseRepository();
  final BudgetDetailFirebaseRepository _fbRepo = BudgetDetailFirebaseRepository();

  Future<AppCategory> loadCategory(int categoryId) {
    return _dbRepo.loadCategory(categoryId);
  }

  Future<Budget> loadBudgetThisMonth(int categoryId, DateTime from, DateTime to) {
    return _dbRepo.loadBudgetThisMonth(categoryId, from, to);
  }

  Future<List<Budget>> findCollapsingBudgets(int catId, DateTime start, DateTime end) {
    return _dbRepo.findCollapsingBudgets(catId, start, end);
  }

  Future<bool> saveBudget(List<Budget> ids, int catId, double amount, DateTime startMonth, DateTime endMonth) async {
    // 
    await _fbRepo.saveBudget(ids, catId, amount, startMonth, endMonth);

    return true;
  }

  Future<int> generateBudgetId() {
    return _dbRepo.generateBudgetId();
  }

  Future<bool> insertBudget(Budget budget) {
    return _fbRepo.insertBudget(budget);
  }

  Future<bool> updateBudget(Budget budget) {
    return _fbRepo.updateBudget(budget);
  }

  Future<bool> deleteBudget(Budget budget) {
    return _fbRepo.deleteBudget(budget);
  }
}

class BudgetDetailDatabaseRepository {

  Future<AppCategory> loadCategory(int categoryId) async {
    List<AppCategory> cats = await db.queryCategory(id: categoryId);

    if(cats != null && cats.length == 1) return cats[0];

    return null;
  }

  Future<Budget> loadBudgetThisMonth(int categoryId, DateTime from, DateTime to) async {
    return await db.findBudget(catId: categoryId,start: from, end: to);
  }

  Future<List<Budget>> findCollapsingBudgets(int catId, DateTime start, DateTime end) async {
    var curBudget = await db.findCollapsingBudgets(catId: catId,start: start, end: end);

    return curBudget;
  }

  Future<int> generateBudgetId() {
    return db.generateBudgetId();
  }
}

class BudgetDetailFirebaseRepository {
  Future<bool> saveBudget(List<Budget> ids, int catId, double amount, DateTime startMonth, DateTime endMonth) async {
//    return fd.addBudget(budget);
    return true;
  }

  Future<bool> insertBudget(Budget budget) {
    return fd.addBudget(budget);
  }

  Future<bool> updateBudget(Budget budget) {
    return fd.updateBudget(budget);
  }

  Future<bool> deleteBudget(Budget budget) {
    return fd.deleteBudget(budget);
  }
}
