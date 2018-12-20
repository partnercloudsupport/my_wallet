import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/budget/list/data/list_repository.dart';
import 'package:my_wallet/ui/budget/budget_config.dart';
import 'package:my_wallet/utils.dart' as Utils;

class ListBudgetsUseCase extends CleanArchitectureUseCase<ListBudgetsRepository> {
  ListBudgetsUseCase() : super(ListBudgetsRepository());

  void loadThisMonthBudgetList(DateTime month, onNext<List<BudgetEntity>> next) async{
    var list = await repo.loadThisMonthBudgetList(month);

    print("list in usecase ${list.length}");
    next(list);
  }

  void loadSummary(onNext<List<BudgetSummary>> next) async {
//    var list = await repo.loadAllBudgets();

    List<BudgetSummary> summary = [];

    DateTime firstDay = await repo.queryMinBudgetStart();
    DateTime lastDay = await repo.queryMaxBudgetEnd();

    while(summary.length < maxMonthSupport || firstDay.isBefore(lastDay)) {
      double budget = 0.0;
      double spend = 0.0;
      double earn = 0.0;

      if(firstDay.isBefore(lastDay)) {
        DateTime end = Utils.lastDayOfMonth(firstDay);
        budget = await repo.queryBudgetAmount(firstDay, end);

        spend = await repo.sumAllTransactionBetweenDateByType(firstDay, end, TransactionType.typeExpense);

        earn = await repo.sumAllTransactionBetweenDateByType(firstDay, end, TransactionType.typeIncome);
      }

      summary.add(BudgetSummary(firstDay, budget == null ? 0 : budget, spend - earn > 0 ? spend - earn : 0));

      if(summary.length % 3 == 0) next(summary);

      firstDay = nextMonthOf(firstDay);
    }

    next(summary);
  }
}