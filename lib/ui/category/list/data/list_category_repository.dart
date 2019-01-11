import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fb;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/category/list/data/list_category_entity.dart';
export 'package:my_wallet/ui/category/list/data/list_category_entity.dart';

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
    return _fbRepo.deleteCategory(cat);
  }

  Future<List<Budget>> findAllBudgets(int catId) {
    return _dbRepo.findAllBudgets(catId);
  }

  Future<void> deleteAllBudgets(List<Budget> budgets) {
    return _fbRepo.deleteAllBudgets(budgets);
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
    return db.findBudget(catid, start, end);
  }

  Future<List<Budget>> findAllBudgets(int catId) {
    return db.findAllBudgetForCategory(catId);
  }
}

class _CategoryListFirebaseRepository {
  Future<bool> deleteCategory(AppCategory cat) {
    return fb.deleteCategory(cat);
  }

  Future<void> deleteAllBudgets(List<Budget> budgets) async {
    if(budgets != null && budgets.isNotEmpty) {
      for(int i = 0; i < budgets.length; i++) {
        await fb.deleteBudget(budgets[i]);
      }
    }
  }
}