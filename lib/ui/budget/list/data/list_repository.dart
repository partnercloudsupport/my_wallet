import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
export 'package:my_wallet/ui/budget/list/data/list_entity.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';

import 'package:my_wallet/utils.dart' as Utils;
export 'package:my_wallet/data/data.dart';

class ListBudgetsRepository extends CleanArchitectureRepository{
  Future<List<BudgetEntity>> loadThisMonthBudgetList(DateTime month) async {
    List<BudgetEntity> entities = [];
    
    List<AppCategory> cats = await db.queryCategory();
    DateTime firstDay = Utils.firstMomentOfMonth(month);
    DateTime lastDay = Utils.lastDayOfMonth(month);
    
    if(cats != null) {
      for(AppCategory f in cats) {
        Budget budget = await db.findBudget(f.id, firstDay, lastDay);

        var spent = 0.0;
        var earn = 0.0;
        var budgetPerMonth = 0.0;

        if(budget != null) {
          spent = budget.spent == null ? 0.0 : budget.spent;
          earn = budget.earn == null ? 0.0 : budget.earn;
          budgetPerMonth = budget.budgetPerMonth == null ? 0.0 : budget.budgetPerMonth;
        }

        entities.add(BudgetEntity(f.id, f.name, spent - earn > 0 ? spent - earn : 0, budgetPerMonth));
      }
    }
    return entities;
  }

  Future<DateTime> queryMinBudgetStart() {
    return db.queryMinBudgetStart();
  }

  Future<DateTime> queryMaxBudgetEnd() {
    return db.queryMaxBudgetEnd();
  }

  Future<double> queryBudgetAmount(DateTime from, DateTime to) async{
    return (await db.queryBudgetAmount(start: from, end: to)).budgetPerMonth;
  }

  Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type) {
    return db.sumAllTransactionBetweenDateByType(from, to, type);
  }

//  Future<List<BudgetSummary>> loadAllBudgets() async {
//    List<BudgetSummary> summary = [];
//
//    DateTime firstDay = await db.queryMinBudgetStart();
//    DateTime lastDay = await db.queryMaxBudgetEnd();
//
//    while(firstDay.isBefore(lastDay)) {
//      DateTime end = Utils.lastDayOfMonth(firstDay);
//      double budget = (await db.queryBudgetAmount(start: firstDay, end: end)).budgetPerMonth;
//
//      double spend = await db.sumAllTransactionBetweenDateByType(firstDay, end, TransactionType.typeExpense);
//
//      double earn = await db.sumAllTransactionBetweenDateByType(firstDay, end, TransactionType.typeIncome);
//
//      summary.add(BudgetSummary(firstDay, budget == null ? 0 : budget, spend - earn > 0 ? spend - earn : 0));
//
//      firstDay = nextMonthOf(firstDay);
//    }
//
//    return summary;
//  }
}