import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/budget/detail/data/detail_repository.dart';
import 'package:my_wallet/utils.dart';

class BudgetDetailUseCase extends CleanArchitectureUseCase<BudgetDetailRepository> {
  BudgetDetailUseCase() : super(BudgetDetailRepository());

  void loadCategoryBudget(int categoryId, DateTime from, DateTime to, onNext<BudgetDetailEntity> next) {
    execute<BudgetDetailEntity>(Future(() async {
      AppCategory category = await repo.loadCategory(categoryId);

      Budget budget = await repo.loadBudgetThisMonth(categoryId, from, to);

      return BudgetDetailEntity(category, budget == null ? 0.0 : budget.budgetPerMonth, budget == null ? from : budget.budgetStart, budget == null ? to : budget.budgetEnd);
    }), next);
  }

  void saveBudget(AppCategory _cat, double _amount, DateTime startMonth, DateTime endMonth, onNext<bool> next, onError error) async {
    execute<bool>(Future(() async {
      var result = false;
      startMonth = firstMomentOfMonth(startMonth);
      if(endMonth != null) endMonth = lastDayOfMonth(endMonth);

      List<Budget> budgets = await repo.findCollapsingBudgets(_cat.id, startMonth, endMonth);

      do {
        // insert new budget
        var id = await repo.generateBudgetId();
        await repo.insertBudget(Budget(id, _cat.id, _amount, startMonth, endMonth));

        result = true;

        // no collapsing budgets, nothing else to do
        if(budgets == null) break;
        if(budgets.isEmpty) break;

        // there are collapsing budget? delete them all
        print("budgets to delete ${budgets.length}");
        for(Budget budget in budgets) {
          print("delete ${budget.id}");
          await repo.deleteBudget(budget);
        }

        print("return result");

      } while(false);

      return result;
    }), next, error: error);
  }
}
