import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/ui/home/chart/transactions/data/transaction_entity.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

class TransactionRepository extends CleanArchitectureRepository{
  final _ChartTransactionDatabaseRepository _dbRepo = _ChartTransactionDatabaseRepository();

  Future<List<TransactionEntity>> loadTransaction(List<TransactionType> type) {
    return _dbRepo.loadTransaction(type);
  }
}

class _ChartTransactionDatabaseRepository {
  Future<List<TransactionEntity>> loadTransaction(List<TransactionType> type) async {

    var from = Utils.firstMomentOfMonth(DateTime.now());
    var to = Utils.lastDayOfMonth(DateTime.now());

    var transactions = await db.queryCategoryWithTransaction(from: from, to: to, type: type, filterZero: true, orderByType: true);
    var total = await db.sumAllTransactionBetweenDateByType(from, to, type);
    List<TransactionEntity> list = transactions == null ? [] : transactions.map((f) => TransactionEntity(f.name, f.income > 0 ? f.income : f.expense > 0 ? f.expense : 0.0, f.colorHex)).toList().sublist(0, transactions.length > 3 ? 3 : transactions.length);

    var balance = list.fold(0.0, (pre, next) => pre + next.amount);

    list.sort((a, b) => b.amount.floor() - a.amount.floor());

    if(total - balance > 0) list.add(TransactionEntity("Others", total - balance, "#1B5E20"));

    return list;
  }
}