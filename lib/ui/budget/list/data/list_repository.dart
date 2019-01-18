import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
export 'package:my_wallet/ui/budget/list/data/list_entity.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';

import 'package:my_wallet/utils.dart' as Utils;
export 'package:my_wallet/data/data.dart';

class ListBudgetsRepository extends CleanArchitectureRepository{
  Future<List<BudgetEntity>> loadThisMonthBudgetList(DateTime month) async {
//    List<BudgetEntity> entities = [];
//
//    List<AppCategory> cats = await db.queryCategory();
//    DateTime firstDay = Utils.firstMomentOfMonth(month);
//    DateTime lastDay = Utils.lastDayOfMonth(month);
//
//    if(cats != null) {
//      for(AppCategory f in cats) {
//        Budget budget = await db.findBudget(catId: f.id, start: firstDay, end: lastDay);
//
//        var spent = 0.0;
//        var earn = 0.0;
//        var budgetPerMonth = 0.0;
//
//        if(budget != null) {
//          budgetPerMonth = budget.budgetPerMonth == null ? 0.0 : budget.budgetPerMonth;
//        }
//
//        spent = await db.sumTransactionsByCategory(catId: f.id, type: TransactionType.typeExpense, start: firstDay, end: lastDay);
//        earn = await db.sumTransactionsByCategory(catId: f.id, type: TransactionType.typeIncome, start: firstDay, end: lastDay);
//
//        entities.add(BudgetEntity(f.id, f.name, spent - earn > 0 ? spent - earn : 0, budgetPerMonth));
//      }
//    }
    return await db.queryCategoryWithBudgetAndTransactionsForMonth<BudgetEntity>(month, (cat, budgetPerMonth, spent, earn) => BudgetEntity(cat.id, cat.name, spent - earn > 0 ? spent - earn : 0, budgetPerMonth));
  }

  Future<DateTime> queryMinBudgetStart() {
    return db.queryMinBudgetStart();
  }

  Future<DateTime> queryMaxBudgetEnd() {
    return db.queryMaxBudgetEnd();
  }

  Future<double> queryBudgetAmount(DateTime from, DateTime to) async{
    var budget = (await db.findBudget(start: from, end: to));

    return budget == null ? 0.0 : budget.budgetPerMonth;
  }

  Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type) {
    return db.sumAllTransactionBetweenDateByType(from, to, type);
  }
}