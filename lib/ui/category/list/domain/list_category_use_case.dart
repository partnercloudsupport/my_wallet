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

        if(budget == null) continue;
        if(budget.spent == null) budget.spent = 0.0;
        if(budget.earn == null) budget.earn = 0.0;

        entities.add(CategoryListItemEntity(f.id, f.name, budget == null || budget.spent == null ? 0.0 : budget.spent, budget == null ? 0.0 : budget.budgetPerMonth));
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
  }
}