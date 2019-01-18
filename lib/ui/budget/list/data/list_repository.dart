import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
export 'package:my_wallet/ui/budget/list/data/list_entity.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';

export 'package:my_wallet/data/data.dart';

class ListBudgetsRepository extends CleanArchitectureRepository{
  Future<List<BudgetEntity>> loadThisMonthBudgetList(DateTime month) async {
    return await db.queryCategoryWithBudgetAndTransactionsForMonth<BudgetEntity>(month, (cat, budgetPerMonth, spent, earn) => BudgetEntity(cat.id, cat.name, cat.colorHex, spent - earn > 0 ? spent - earn : 0, budgetPerMonth));
  }

  Future<DateTime> queryMinBudgetStart() {
    return db.queryMinBudgetStart();
  }

  Future<DateTime> queryMaxBudgetEnd() {
    return db.queryMaxBudgetEnd();
  }

  Future<double> queryBudgetAmount(DateTime from, DateTime to) async{
    var budget = await db.querySumAllBudgetForMonth(from, to);

    return budget == null ? 0.0 : budget;
  }

  Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type) {
    return db.sumAllTransactionBetweenDateByType(from, to, type);
  }
}