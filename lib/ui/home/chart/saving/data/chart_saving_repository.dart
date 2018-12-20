import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';

class SavingChartRepository extends CleanArchitectureRepository {
  Future<SavingEntity> loadSaving() async {
    var start = Utils.firstMomentOfMonth(DateTime.now());
    var today = DateTime.now();

    var expenseThisMonth = await _db.sumAllTransactionBetweenDateByType(start, today, TransactionType.typeExpense) ?? 0.0;

    var monthlyBudget = await _db.sumAllBudget(start, Utils.lastDayOfMonth(start)) ?? 0.0;

    return SavingEntity(expenseThisMonth, monthlyBudget == 0 ? 0.0 : expenseThisMonth < monthlyBudget ? expenseThisMonth / monthlyBudget : 1.0);
  }
}