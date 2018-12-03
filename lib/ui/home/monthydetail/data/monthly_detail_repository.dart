import 'package:my_wallet/ui/home/monthydetail/data/monthly_detail_entity.dart';

import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/database/database_manager.dart' as _db;

class HomeMonthlyDetailRepository {
  final _HomeMonthlyDetailDatabaseRepository _dbRepo = _HomeMonthlyDetailDatabaseRepository();

  Future<HomeMonthlyDetailEntity> loadData() {
    return _dbRepo.loadData();
  }
}

class _HomeMonthlyDetailDatabaseRepository {

  Future<HomeMonthlyDetailEntity> loadData() async {
    var income = 0.0;
    var expenses = 0.0;

    List<AppTransaction> transactions = await _db.queryTransactions();

    if (transactions != null && transactions.isNotEmpty) {
      transactions.forEach((f) {
        if(f.type == TransactionType.Expenses) {
          expenses += f.amount;
        }

        if (f.type == TransactionType.Income) {
          income += f.amount;
        }
      });
    }

    return HomeMonthlyDetailEntity(income, expenses, income - expenses);
  }
}