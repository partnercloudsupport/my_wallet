import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
export 'package:my_wallet/ui/budget/list/data/list_entity.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';

import 'package:my_wallet/utils.dart' as Utils;

class ListBudgetsRepository extends CleanArchitectureRepository{
  Future<List<BudgetEntity>> loadThisMonthBudgetList() async {
    List<BudgetEntity> entities = [];
    
    List<AppCategory> cats = await db.queryCategory();
    DateTime now = DateTime.now();
    DateTime firstDay = Utils.firstMomentOfMonth(now);
    DateTime lastDay = Utils.lastDayOfMonth(now);
    
    if(cats != null) {
      for(AppCategory f in cats) {
        double budget = await db.queryBudgetAmount(catId : f.id, start: firstDay, end: lastDay);

        double spend = await db.sumTransactionsByCategory(catId: f.id, type: TransactionType.typeExpense, start: firstDay, end: lastDay);

        double earn = await db.sumTransactionsByCategory(catId: f.id, type: TransactionType.typeIncome, start: firstDay, end: lastDay);

        entities.add(BudgetEntity(f.name, spend - earn, budget == null ? 0 : budget));
      }
    }
    return entities;
  }
}