import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/budget/detail/data/detail_repository.dart';
import 'package:my_wallet/utils.dart';

class BudgetDetailUseCase extends CleanArchitectureUseCase<BudgetDetailRepository> {
  BudgetDetailUseCase() : super(BudgetDetailRepository());

  void loadCategoryList(onNext<List<AppCategory>> next) {
    repo.loadCategoryList().then((value) => next(value));
  }

  void loadCategoryBudget(int categoryId, DateTime from, DateTime to, onNext<BudgetDetailEntity> next) async {
    AppCategory category = await repo.loadCategory(categoryId);

    Budget budget = await repo.loadBudgetThisMonth(categoryId, from, to);

    next(BudgetDetailEntity(category, budget == null ? 0.0 : budget.budgetPerMonth, budget == null ? DateTime.now() : budget.budgetStart, budget == null ? DateTime.now() : budget.budgetEnd));
  }

  void saveBudget(AppCategory _cat, double _amount, DateTime startMonth, DateTime endMonth, onNext<bool> next, onError error) async {
    try {
      startMonth = firstMomentOfMonth(startMonth);
      endMonth = lastDayOfMonth(endMonth);

      var date = startMonth;

      while (date.isBefore(endMonth)) {
        var end = lastDayOfMonth(date);

        int id = await repo.findBudgetId(_cat.id, date, end);

        // save multiple budgets, 1 budget per month
        Budget budget = Budget(id, _cat.id, _amount, date, end);
        await repo.saveBudget(budget);

//        await Future.delayed(Duration(seconds: 2));

        var month = date.month + 1;
        var year = date.year;

        if (month > 12) {
          month -= 12;
          year += 1;
        }
        date = DateTime(year, month, 1);
      }

      next(true);
    } catch (e) {
      error(e);
    }
  }
}
