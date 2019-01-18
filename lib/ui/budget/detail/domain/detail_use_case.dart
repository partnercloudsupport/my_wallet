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
    }), next, (e) {
      print("load category budget failed");
      next(null);
    });
  }

  void saveBudget(AppCategory _cat, double _amount, DateTime _startMonth, DateTime _endMonth, onNext<bool> next, onError error) async {
    execute<bool>(Future(() async {
      var result = true;
      DateTime startMonth = firstMomentOfMonth(_startMonth);
      DateTime endMonth;
      if(_endMonth != null) endMonth = lastDayOfMonth(_endMonth);

      List<Budget> budgets = await repo.findCollapsingBudgets(_cat.id, startMonth, endMonth);

      print("save with endmonth $endMonth");
      do {
        // insert new budget
        var id = await repo.generateBudgetId();
        await repo.insertBudget(Budget(id, _cat.id, _amount, startMonth, endMonth));

        if (budgets == null || budgets.isEmpty) {
          break;
        }

        if(endMonth == null) {
          for(Budget budget in budgets) {
            // delete all budgets which starts same or after start month
            if(budget.budgetStart.isAfter(startMonth) || budget.budgetStart.isAtSameMomentAs(startMonth)) {
              await repo.deleteBudget(budget);
            }
            // update this budget to set its endDate to be the new Start
            else {
              await repo.updateBudget(Budget(budget.id, _cat.id, budget.budgetPerMonth, budget.budgetStart, startMonth.subtract(Duration(milliseconds: 1))));
            }
          }

          break;
        }

        // if there's a fix period, need ot check all available budget
        for(Budget budget in budgets) {
          /// collapse can happens
          /// old budget starts same moment as new budget
          if(budget.budgetStart.isAtSameMomentAs(startMonth)) {
            if(budget.budgetEnd == null || budget.budgetEnd.isAfter(endMonth)) {
              /// ------------------|period of new budget |-------------------
              /// ------------------| same start time , and it never ends, or ends later than new budget
              await repo.updateBudget(Budget(budget.id, budget.categoryId, budget.budgetPerMonth, endMonth.add(Duration(milliseconds: 1)), budget.budgetEnd));
            }
            /// ------------------|period of new budget |-------------------
            /// ------------------| same start time |-----------------------
            else {
              // delete
              await repo.deleteBudget(budget);
            }
          }
          /// old budget starts before new budget
          else if(budget.budgetStart.isBefore(startMonth)) {
            /// ------------------|period of new budget |-------------------
            /// --------------|start before and ends after new budget |-----
            if(budget.budgetEnd == null || budget.budgetEnd.isAfter(endMonth)) {
              // break it into 2 budgets
              var id = await repo.generateBudgetId();

              await repo.insertBudget(Budget(id, _cat.id, budget.budgetPerMonth, budget.budgetStart, startMonth.subtract(Duration(milliseconds: 1))));
              // end update the current budget with new start date
              await repo.updateBudget(Budget(budget.id, _cat.id, budget.budgetPerMonth, endMonth.add(Duration(milliseconds: 1)), budget.budgetEnd));
            }
            /// ------------------|period of new budget |-------------------
            /// --------------|start before |---------------------------------
            else {
              // update budget end to be this start month
              await repo.updateBudget(Budget(budget.id, _cat.id, budget.budgetPerMonth, budget.budgetStart, startMonth.subtract(Duration(milliseconds: 1))));
            }
          }
          /// old budget starts after new budget starts
          else if(budget.budgetStart.isAfter(startMonth)) {
            /// ------------------|period of new budget |-------------------
            /// -----------------------------|update start after new budget, and ends after new budget ends
            if(budget.budgetEnd == null || budget.budgetEnd.isAfter(endMonth)) {
              // update its new start
              await repo.updateBudget(Budget(budget.id, budget.categoryId, budget.budgetPerMonth, endMonth.add(Duration(milliseconds: 1)), budget.budgetEnd));
            }
            /// ------------------|period of new budget |-------------------
            /// ---------------------|budget period|------------------------
            else {
              // delete this
              await repo.deleteBudget(budget);
            }
          }
        }
      } while(false);

      return result;
    }), next, error);
  }
}
