import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/ui/home/chart/expense/data/expense_entity.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/database/data.dart';

class ChartExpenseRepository {
  final _ChartExpenseDatabaseRepository _dbRepo = _ChartExpenseDatabaseRepository();

  Future<List<ExpenseEntity>> loadExpense() {
    return _dbRepo.loadExpense();
  }
}

class _ChartExpenseDatabaseRepository {
  Future<List<ExpenseEntity>> loadExpense() async {

    var from = Utils.firstMomentOfMonth(DateTime.now());
    var to = Utils.lastDayOfMonth(DateTime.now());

    var transactions = await db.queryCategoryWithTransaction(from: from, to: to, type: TransactionType.typeExpense, filterZero: true);

    // debug purpose
    print("expenses transaction: ${transactions.length}");
    transactions.forEach((f) => print("transaction ${f.name} amount ${f.balance}"));
    return transactions == null ? [] : transactions.map((f) => ExpenseEntity(f.name, f.balance, f.colorHex)).toList();
  }
}