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
    List<AppTransaction> transactions = await db.queryTransactionsBetweenDates(Utils.firstMomentOfMonth(DateTime.now()), Utils.lastDayOfMonth(DateTime.now()));

    List<TransactionEntity> income = [];
    List<TransactionEntity> expense = [];

    if (transactions != null) {
      transactions.forEach((f) {
        switch(f.type) {
          case TransactionType.Income:
            income.add(TransactionEntity(f.dateTime, f.amount));
            break;
          case TransactionType.Expenses:
            expense.add(TransactionEntity(f.dateTime, f.amount));
            break;
        }
      });
    }

    income.sort((a, b) => b.month.millisecond - a.month.millisecond);
    expense.sort((a, b) => b.month.millisecond - a.month.millisecond);

    return ChartEntity(income, expense);
  }
}
