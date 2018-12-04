import 'package:my_wallet/ui/home/expenses/data/expenses_entity.dart';
import 'package:my_wallet/database/database_manager.dart' as _db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/database/data.dart';


class ExpensesRepository {
  final _ExpensesDatabaseRepository _dbRepo = _ExpensesDatabaseRepository();
  Future<List<ExpeneseEntity>> loadExpenses() {
    return _dbRepo.loadExpenses();
  }
}

class _ExpensesDatabaseRepository {
  Future<List<ExpeneseEntity>> loadExpenses() async {
    List<AppCategory> cats = await _db.queryCategoryWithTransaction(from: Utils.firstMomentOfMonth(DateTime.now()), to: Utils.lastDayOfMonth(DateTime.now()), filterZero: true);

    return cats == null ? [] : cats.map((f) => ExpeneseEntity(f.id, f.name, f.balance, f.transactionType, f.colorHex)).toList();
  }
}