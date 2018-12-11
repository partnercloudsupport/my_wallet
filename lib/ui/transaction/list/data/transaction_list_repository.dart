import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';

class TransactionListRepository extends CleanArchitectureRepository {
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
    List<AppTransaction> transactions = [];
    if(accountId != null) {
      transactions = await db.queryTransactionForAccount(accountId);
    }

    if(categoryId != null) {
      transactions = await db.queryTransactionForCategory(categoryId);
    }

    if(day != null) {
      transactions = await db.queryTransactionsBetweenDates(Utils.startOfDay(day), Utils.endOfDay(day));
    }

    // update category names to transactions which does not have description
    List<AppTransaction> noDesc = transactions.where((f) => f.desc == null || f.desc.isEmpty).toList();

    if(noDesc != null && noDesc.isNotEmpty) {
      transactions.removeWhere((f) => f.desc == null || f.desc.isEmpty);

      if(categoryId != null) {
        var cat = await db.queryCategory(id: categoryId);

        noDesc.forEach((f) => transactions.add(AppTransaction(f.id, f.dateTime, f.accountId, f.categoryId, f.amount, cat[0].name, f.type)));
      } else {
        for (int i = 0; i < noDesc.length; i++) {
          var cat = await db.queryCategory(id: noDesc[i].categoryId);

          transactions.add(AppTransaction(noDesc[i].id, noDesc[i].dateTime, noDesc[i].accountId, noDesc[i].categoryId, noDesc[i].amount, cat[0].name, noDesc[i].type));
        }
      }
    }

    // sort transactions by date
    transactions.sort((a, b) => a.dateTime.millisecondsSinceEpoch - b.dateTime.millisecondsSinceEpoch);

    return transactions;
  }
}