import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';

class SavingChartRepository extends CleanArchitectureRepository {
  Future<SavingEntity> loadSaving() async {
    var start = Utils.firstMomentOfMonth(DateTime.now());
    var today = DateTime.now();


    var incomeThisMonth = await _db.sumAllTransactionBetweenDateByType(start, today, TransactionType.typeIncome);
    var expenseThisMonth = await _db.sumAllTransactionBetweenDateByType(start, today, TransactionType.typeExpense);

    var monthlySaving = incomeThisMonth - expenseThisMonth;

    var monthlyBudget = await _db.sumAllBudget(start, Utils.lastDayOfMonth(start));

    return SavingEntity(monthlySaving, monthlySaving > 0 ? monthlyBudget > 0 ? monthlySaving/monthlyBudget : 1.0 : 0.0);
  }
}