import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/ui/home/chart/income/data/income_entity.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/database/data.dart';

class ChartIncomeRepository {
  final _ChartIncomeDatabaseRepository _dbRepo = _ChartIncomeDatabaseRepository();

  Future<List<IncomeEntity>> loadIncome() {
    return _dbRepo.loadIncome();
  }
}

class _ChartIncomeDatabaseRepository {
  Future<List<IncomeEntity>> loadIncome() async {

    var from = Utils.firstMomentOfMonth(DateTime.now());
    var to = Utils.lastDayOfMonth(DateTime.now());

    var transactions = await db.queryCategoryWithTransaction(from: from, to: to, type: TransactionType.Income, filterZero: true);

    return transactions == null ? [] : transactions.map((f) => IncomeEntity(f.name, f.balance, f.colorHex)).toList();
  }
}