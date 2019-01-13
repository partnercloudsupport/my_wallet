import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/ui/home/homemain/data/homemain_expenses_entity.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/utils.dart' as Utils;
export 'package:my_wallet/ui/home/homemain/data/homemain_expenses_entity.dart';

class MyWalletHomeRepository extends CleanArchitectureRepository {
  final _MyWalletHomeDatabaseRepository _dbRepo = _MyWalletHomeDatabaseRepository();
  Future<List<ExpenseEntity>> loadExpense() {
    return _dbRepo.loadExpense();
  }
}

class _MyWalletHomeDatabaseRepository {
  Future<List<ExpenseEntity>> loadExpense() async {
    var start = Utils.firstMomentOfMonth(DateTime.now());
    var end = Utils.lastDayOfMonth(DateTime.now());

    List<AppCategory> cats = await _db.queryCategoryWithTransaction(from: start, to: end, filterZero: false);

    List<ExpenseEntity> homeEntities = [];

    if (cats != null && cats.isNotEmpty) {
      for(int i = 0; i < cats.length; i++) {
        var budget = await _db.queryBudgetAmount(start: start, end: end, catId: cats[i].id);

        var remainFactor = 1 - (budget == null || budget.budgetPerMonth == 0 ? 0.0 : cats[i].expense/budget.budgetPerMonth);

        if(remainFactor < 0) remainFactor = 0;

        homeEntities.add(ExpenseEntity(cats[i].id, cats[i].name, cats[i].income, cats[i].expense, cats[i].colorHex, remainFactor, budget.budgetPerMonth));
      }
    }

    return homeEntities;
  }
}