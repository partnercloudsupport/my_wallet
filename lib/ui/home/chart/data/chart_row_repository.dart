import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/home/chart/data/chart_entity.dart';

class ChartRepository {
  final _ChartDatabaseRepository _dbRepo = _ChartDatabaseRepository();

  Future<ChartEntity> loadChartData() {
    return _dbRepo.loadChartData();
  }
}

class _ChartDatabaseRepository {
  Future<ChartEntity> loadChartData() async {
    var end = Utils.lastDayOfMonth(DateTime.now());

    var day = Utils.firstMomentOfMonth(DateTime.now());

    List<TransactionEntity> income = [];
    List<TransactionEntity> expense = [];

    while(day.isBefore(end)) {
      var incomeByDay = await db.sumTransactionsByDay(day, TransactionType.Income);
      var expensesByDay = await db.sumTransactionsByDay(day, TransactionType.Expenses);

      if (incomeByDay != null) income.add(TransactionEntity(day, incomeByDay));
      else income.add(TransactionEntity(day, 0));

      if (expensesByDay != null) expense.add(TransactionEntity(day, expensesByDay));
      else expense.add(TransactionEntity(day, 0));

      day = day.add(Duration(days: 1));
    }

    return ChartEntity(income, expense);
  }
}
