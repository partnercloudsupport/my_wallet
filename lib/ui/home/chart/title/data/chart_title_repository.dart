import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';

class ChartTitleRepository extends CleanArchitectureRepository{
  Future<ChartTitleEntity> loadTitleDetail() async {
    var from = Utils.firstMomentOfMonth(DateTime.now());
    var to = Utils.lastDayOfMonth(DateTime.now());

    var income = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeIncome) ?? 0;
    var expenses = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeExpense) ?? 0;
    var budget = await _db.querySumAllBudgetForMonth(from, to, CategoryType.expense);

    return ChartTitleEntity(expenses, income, budget == 0 ? 0.0 : expenses < budget ? expenses / budget : 1.0);
  }
}