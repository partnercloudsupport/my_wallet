import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';

class ExpenseRepository extends CleanArchitectureRepository {
  final _ExpenseDatabaseRepository _dbRepo = _ExpenseDatabaseRepository();
  Future<List<ExpenseEntity>> loadExpense() {
    return _dbRepo.loadExpense();
  }
}

class _ExpenseDatabaseRepository {
  Future<List<ExpenseEntity>> loadExpense() async {
    List<AppCategory> cats = await _db.queryCategoryWithTransaction(from: Utils.firstMomentOfMonth(DateTime.now()), to: Utils.lastDayOfMonth(DateTime.now()), filterZero: false);

    List<ExpenseEntity> homeEntities = cats == null ? [] : cats.map((f) => ExpenseEntity(f.id, f.name, f.balance, f.colorHex)).toList();

    return homeEntities;
  }
}