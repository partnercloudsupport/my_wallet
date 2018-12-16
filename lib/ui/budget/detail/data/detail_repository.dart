import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fd;
export 'package:my_wallet/data/data.dart';

class BudgetDetailRepository extends CleanArchitectureRepository {
  final BudgetDetailDatabaseRepository _dbRepo = BudgetDetailDatabaseRepository();
  final BudgetDetailFirebaseRepository _fbRepo = BudgetDetailFirebaseRepository();

  Future<List<AppCategory>> loadCategoryList() {
    return _dbRepo.loadCategoryList();
  }

  Future<int> generateBudgetId() {
    return _dbRepo.generateBudgetId();
  }

  Future<bool> saveBudget(Budget budget) {
    return _fbRepo.saveBudget(budget);
  }
}

class BudgetDetailDatabaseRepository {

  Future<List<AppCategory>> loadCategoryList() {
    return db.queryCategory();
  }

  Future<int> findBudgetId(int catId, DateTime startMonth, DateTime endMonth ) {
    return db.queryBudget(catId: catId, start: startMonth, end: endMonth);
  }
  Future<int> generateBudgetId() {
    return db.generateBudgetId();
  }
}

class BudgetDetailFirebaseRepository {
  Future<bool> saveBudget(Budget budget) {
    return fd.addBudget(budget);
  }
}