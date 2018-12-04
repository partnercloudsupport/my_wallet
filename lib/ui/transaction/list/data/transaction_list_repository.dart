import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/utils.dart' as Utils;

class TransactionListRepository {
  final _TransactionListDatabaseRepository _dbRepo = _TransactionListDatabaseRepository();

  Future<List<AppTransaction>> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) {
    return _dbRepo.loadDataFor(accountId, categoryId, day);
  }
}

class _TransactionListDatabaseRepository {
  Future<List<AppTransaction>> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) async {
    if(accountId != null) {
      return await db.queryTransactionForAccount(accountId);
    }

    if(categoryId != null) {
      return await db.queryTransactionForCategory(categoryId);
    }

    if(day != null) {
      return await db.queryTransactionsBetweenDates(Utils.startOfDay(day), Utils.endOfDay(day));
    }
    return [];
  }
}