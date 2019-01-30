import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/budget/list/data/list_repository.dart';
import 'package:my_wallet/ui/budget/budget_config.dart';
import 'package:my_wallet/utils.dart' as Utils;

class ListBudgetsUseCase extends CleanArchitectureUseCase<ListBudgetsRepository> {
  ListBudgetsUseCase() : super(ListBudgetsRepository());

  void loadThisMonthBudgetList(DateTime month, onNext<BudgetListEntity> next) async {
    execute<BudgetListEntity>(repo.loadThisMonthBudgetList(month), next, (e) {
      debugPrint("Load this month budget error $e");
      next(BudgetListEntity.empty());
    });
  }

  ///////////////////////////////////////////////////////////////
  /// Summary is loaded as month by month basic
  ///////////////////////////////////////////////////////////////
  void loadSummary(onNext<List<BudgetSummary>> next) async {
    execute<List<BudgetSummary>>(Future(() async {
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

        summary.add(BudgetSummary(firstDay, budget == null ? 0.0 : budget, spend - earn > 0.0 ? spend - earn : 0.0));

        firstDay = nextMonthOf(firstDay);
      }

      return summary;
    }), next, (e) {
      debugPrint("Load summary error $e");
      next([]);
    });
  }
}
