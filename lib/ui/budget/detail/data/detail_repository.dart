import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fd;

import 'package:my_wallet/ui/budget/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/budget/detail/data/detail_entity.dart';

class BudgetDetailRepository extends CleanArchitectureRepository {
  final BudgetDetailDatabaseRepository _dbRepo = BudgetDetailDatabaseRepository();
  final BudgetDetailFirebaseRepository _fbRepo = BudgetDetailFirebaseRepository();

  Future<List<AppCategory>> loadCategoryList() {
    return _dbRepo.loadCategoryList();
  }

  Future<AppCategory> loadCategory(int categoryId) {
    return _dbRepo.loadCategory(categoryId);
  }

  Future<Budget> loadBudgetThisMonth(int categoryId) {
    return _dbRepo.loadBudgetThisMonth(categoryId);
  }

  Future<int> findBudgetId(int catId, DateTime start, DateTime end) {
    return _dbRepo.findBudgetId(catId, start, end);
  }

  Future<bool> saveBudget(Budget budget) async {
    await _fbRepo.saveBudget(budget);
    await _dbRepo.saveBudget(budget);

    return true;
  }
}

class BudgetDetailDatabaseRepository {

  Future<List<AppCategory>> loadCategoryList() {
    return db.queryCategory();
  }

  Future<AppCategory> loadCategory(int categoryId) async {
    List<AppCategory> cats = await db.queryCategory(id: categoryId);

    if(cats != null && cats.length == 1) return cats[0];

    return null;
  }

  Future<Budget> loadBudgetThisMonth(int categoryId) async {
    return await db.queryBudgetAmount(catId: categoryId, start: DateTime.now(), end: DateTime.now());
  }

  Future<int> findBudgetId(int catId, DateTime start, DateTime end) async {
    var curBudget = await db.findBudget(catId, start, end);

    print("current id for $start to $end is ${curBudget == null ? "not found" : curBudget.id}");
    return curBudget == null ? await db.generateBudgetId() : curBudget.id;
  }

  Future<bool> saveBudget(Budget budget) async {
    db.insertBudget(budget).catchError((e) => db.updateBudget(budget));
    return true;
  }
}

class BudgetDetailFirebaseRepository {
  Future<bool> saveBudget(Budget budget) {
    return fd.addBudget(budget);
  }
}