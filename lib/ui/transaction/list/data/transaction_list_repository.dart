import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/ui/transaction/list/data/transaction_list_entity.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/style/app_theme.dart';

class TransactionListRepository extends CleanArchitectureRepository {
  final _TransactionListDatabaseRepository _dbRepo = _TransactionListDatabaseRepository();

  Future<TransactionListEntity> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) {
    return _dbRepo.loadDataFor(accountId, categoryId, day);
  }
}

class _TransactionListDatabaseRepository {
  Future<TransactionListEntity> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) async {
    List<TransactionEntity> entities = [];
    List<DateTime> dates = [];
    var total = 0.0;

    List<AppTransaction> transactions = [];
    if(accountId != null) {
      transactions = await db.queryTransactionForAccount(accountId, day);
      dates = await db.findTransactionsDates(day, accountId : accountId, categoryId : categoryId, );
    }

    if(categoryId != null) {
      transactions = await db.queryTransactionForCategory(categoryId, day);
      dates = await db.findTransactionsDates(day, accountId : accountId, categoryId : categoryId, );
      var budgetAmount = await db.queryBudgetAmount(start: Utils.firstMomentOfMonth(day == null ? DateTime.now() : day), end: Utils.lastDayOfMonth(day == null ? DateTime.now() : day), catId: categoryId);
    }

    if(accountId == null && categoryId == null && day != null) {
      // only load for days when there's no account or category required
      transactions = await db.queryTransactionsBetweenDates(Utils.startOfDay(day), Utils.endOfDay(day));
      dates = await db.findTransactionsDates(day, accountId : accountId, categoryId : categoryId, );
    }

    if (transactions != null) {
      // update category names to transactions which does not have description
      List<AppTransaction> noDesc = transactions.where((f) => f.desc == null || f.desc.isEmpty).toList();

      if (noDesc != null && noDesc.isNotEmpty) {
        transactions.removeWhere((f) => f.desc == null || f.desc.isEmpty);

        if (categoryId != null) {
          var cat = await db.queryCategory(id: categoryId);

          noDesc.forEach((f) =>
              transactions.add(AppTransaction(
                  f.id,
                  f.dateTime,
                  f.accountId,
                  f.categoryId,
                  f.amount,
                  cat[0].name,
                  f.type,
                  f.userUid)));
        } else {
          for (int i = 0; i < noDesc.length; i++) {
            var cat = await db.queryCategory(id: noDesc[i].categoryId);

            transactions.add(AppTransaction(
                noDesc[i].id,
                noDesc[i].dateTime,
                noDesc[i].accountId,
                noDesc[i].categoryId,
                noDesc[i].amount,
                cat[0].name,
                noDesc[i].type,
                noDesc[i].userUid));
          }
        }
      }

      // sort transactions by date
      transactions.sort((a, b) => a.dateTime.millisecondsSinceEpoch - b.dateTime.millisecondsSinceEpoch);

      // get user initial
      for(AppTransaction trans in transactions) {
        if(trans.userUid == null || trans.userUid.isEmpty) continue;

        List<User> users = await db.queryUser(uuid: trans.userUid);

        if(users != null && users.isNotEmpty) {
          User user = users[0];
          var splits = user.displayName.split(" ");
          var initial = splits.map((f) => f.substring(0, 1).toUpperCase()).join();
          initial = initial.substring(0, initial.length < 2 ? initial.length : 2);

          total += TransactionType.isExpense(trans.type) ? trans.amount : 0.0;
          entities.add(TransactionEntity(trans.id, initial, trans.desc, trans.amount, trans.dateTime, user.color, TransactionType.isIncome(trans.type) ? AppTheme.tealAccent.value : AppTheme.pinkAccent.value));
        }
      }
    }

    var budget = await db.queryBudgetAmount(start: Utils.firstMomentOfMonth(day == null ? DateTime.now() : day), end: Utils.lastDayOfMonth(day == null ? DateTime.now() : day), catId: categoryId);
    var fraction = budget == null || budget.budgetPerMonth == 0 ? 1.0 : total/budget.budgetPerMonth;
    return TransactionListEntity(entities, dates, total, fraction);
  }
}
