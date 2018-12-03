import 'package:my_wallet/ui/home/monthydetail/data/monthly_detail_entity.dart';

import 'package:my_wallet/database/database_manager.dart' as _db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/database/data.dart';

class HomeMonthlyDetailRepository {
  final _HomeMonthlyDetailDatabaseRepository _dbRepo = _HomeMonthlyDetailDatabaseRepository();

  Future<HomeMonthlyDetailEntity> loadData() {
    return _dbRepo.loadData();
  }
}

class _HomeMonthlyDetailDatabaseRepository {

  Future<HomeMonthlyDetailEntity> loadData() async {
    var from = Utils.firstMomentOfMonth(DateTime.now());
    var to = Utils.lastDayOfMonth(DateTime.now());

    var income = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.Income);
    var expenses = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.Expenses);

    return HomeMonthlyDetailEntity(income, expenses, income - expenses);
  }
}