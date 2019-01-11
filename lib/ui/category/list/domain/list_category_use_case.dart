import 'package:my_wallet/ui/category/list/data/list_category_repository.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/utils.dart' as Utils;

class ListCategoryUseCase extends CleanArchitectureUseCase<CategoryListRepository>{
  ListCategoryUseCase() : super(CategoryListRepository());

  void loadCategories(onNext<List<CategoryListItemEntity>> next) async {
    List<CategoryListItemEntity> entities = [];

    var cats = await repo.loadCategories();

    var month = DateTime.now();

    DateTime firstDay = Utils.firstMomentOfMonth(month);
    DateTime lastDay = Utils.lastDayOfMonth(month);

    if(cats != null) {
      for(AppCategory f in cats) {
        Budget budget = await repo.findBudget(f.id, firstDay, lastDay);

        var spent = 0.0;
        var budgetPerMonth = 0.0;

        if(budget != null) {
          spent = budget.spent == null ? 0.0 : budget.spent;
          budgetPerMonth = budget.budgetPerMonth == null ? 0.0 : budgetPerMonth;
        }

        entities.add(CategoryListItemEntity(f.id, f.name, spent, budgetPerMonth));
      }
    }

    next(entities);
  }

  void deleteCategory(int catId) async {
    AppCategory cat = await repo.loadCategory(catId);

    if(cat != null) await repo.deleteCategory(cat);

    // delete all budgets for this category
    List<Budget> budgets = await repo.findAllBudgets(catId);

    if(budgets != null && budgets.isNotEmpty) {
      await repo.deleteAllBudgets(budgets);
    }

    List<AppTransaction> transactions = await repo.findAllTransaction(catId);
    if(transactions != null && transactions.isNotEmpty) {
      await repo.deleteAllTransactions(transactions);
    }
  }
}