import 'package:my_wallet/ui/category/list/data/list_category_repository.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/utils.dart' as Utils;

class ListCategoryUseCase extends CleanArchitectureUseCase<CategoryListRepository>{
  ListCategoryUseCase() : super(CategoryListRepository());

  void loadCategories(onNext<List<CategoryListItemEntity>> next) async {
    execute<List<CategoryListItemEntity>>(Future(() async {
      List<CategoryListItemEntity> entities = [];

      var cats = await repo.loadCategories();

      var month = DateTime.now();

      if(cats != null) {
        for(AppCategory f in cats) {
          Budget budget = await repo.findBudget(f.id, month, month);

          var spent = 0.0;
          var budgetPerMonth = 0.0;

          spent = await repo.sumSpentPerMonthByCategory(f.id, month);

          if(budget != null) {
            budgetPerMonth = budget.budgetPerMonth == null ? 0.0 : budget.budgetPerMonth;
          }

          entities.add(CategoryListItemEntity(f.id, f.name, spent, budgetPerMonth));
        }
      }

      return entities;
    }), next, (e) {
      print("Load categories error $e");
      next([]);
    });
  }

  void deleteCategory(int catId) async {
    execute<void>(Future(() async{
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

      return;
    }), (_) {}, (e) {});
  }
}