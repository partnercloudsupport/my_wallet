import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
export 'package:my_wallet/ui/budget/list/data/list_entity.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';

export 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;

class ListBudgetsRepository extends CleanArchitectureRepository{
  Future<BudgetListEntity> loadThisMonthBudgetList(DateTime month) async {
    var start = Utils.firstMomentOfMonth(month);
    var end = Utils.lastDayOfMonth(month);
    List<BudgetEntity> income = await db.queryCategoryWithBudgetAndTransactionsForMonth<BudgetEntity>(month, CategoryType.income, (cat, budgetPerMonth, transaction) => BudgetEntity(cat.id, cat.name, cat.colorHex, transaction, budgetPerMonth, CategoryType.income));
    List<BudgetEntity> expense = await db.queryCategoryWithBudgetAndTransactionsForMonth<BudgetEntity>(month, CategoryType.expense, (cat, budgetPerMonth, transaction) => BudgetEntity(cat.id, cat.name, cat.colorHex, transaction, budgetPerMonth, CategoryType.expense));

    var incomeBudget = await db.querySumAllBudgetForMonth(start, end, CategoryType.income);
    var expenseBudget = await db.querySumAllBudgetForMonth(start, end, CategoryType.expense);

    var totalIncome = await db.sumAllTransactionBetweenDateByType(start, end, TransactionType.typeIncome);
    var totalExpense = await db.sumAllTransactionBetweenDateByType(start, end, TransactionType.typeExpense);

    return BudgetListEntity(income, expense, incomeBudget, expenseBudget, totalIncome, totalExpense);
  }

  Future<DateTime> queryMinBudgetStart() {
    return db.queryMinBudgetStart();
  }

  Future<DateTime> queryMaxBudgetEnd() {
    return db.queryMaxBudgetEnd();
  }

  Future<double> queryBudgetAmount(DateTime from, DateTime to) async{
    var incomeBudget = await db.querySumAllBudgetForMonth(from, to, CategoryType.income);
    var expenseBudget = await db.querySumAllBudgetForMonth(from, to, CategoryType.expense);

    print("income budget $incomeBudget and expense $expenseBudget");

    var budget = await db.querySumAllBudgetForMonth(from, to, CategoryType.expense);
    return budget == null ? 0.0 : budget;
  }

  Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type) {
    return db.sumAllTransactionBetweenDateByType(from, to, type);
  }
}