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
    }

    if(accountId == null && categoryId == null && day != null) {
      // only load for days when there's no account or category required
      transactions = await db.queryTransactionsBetweenDates(Utils.startOfDay(day), Utils.endOfDay(day));
      dates = await db.findTransactionsDates(day, accountId : accountId, categoryId : categoryId, );
    }

    if (transactions != null) {
      // sort transactions by date
      transactions.sort((a, b) => a.dateTime.millisecondsSinceEpoch - b.dateTime.millisecondsSinceEpoch);

      Map<int, String> categoryNames = {};

      for(AppTransaction trans in transactions) {
        if(trans.userUid == null || trans.userUid.isEmpty) continue;

        // get category name
        var catName = categoryNames[trans.categoryId];

        if(catName == null) {
          var category = await db.queryCategory(id: trans.categoryId);
          if(category != null && category.isNotEmpty) catName = category[0].name;

          // put category name for this ID into map, to be reused later
          categoryNames.putIfAbsent(trans.categoryId, () => catName);
        }

        // get user initial
        List<User> users = await db.queryUser(uuid: trans.userUid);

        if(users != null && users.isNotEmpty) {
          User user = users[0];
          var splits = user.displayName.split(" ");
          var initial = splits.map((f) => f.substring(0, 1).toUpperCase()).join();
          initial = initial.substring(0, initial.length < 2 ? initial.length : 2);

          total += TransactionType.isExpense(trans.type) ? trans.amount : 0.0;
          entities.add(TransactionEntity(trans.id, initial, catName, trans.desc, trans.amount, trans.dateTime, user.color, TransactionType.isIncome(trans.type) ? AppTheme.tealAccent.value : AppTheme.pinkAccent.value));
        }
      }
    }

    var budget = await db.queryBudgetAmount(start: Utils.firstMomentOfMonth(day == null ? DateTime.now() : day), end: Utils.lastDayOfMonth(day == null ? DateTime.now() : day), catId: categoryId);
    var fraction = budget == null || budget.budgetPerMonth == 0 ? 1.0 : total/budget.budgetPerMonth;
    return TransactionListEntity(entities, dates, total, fraction);
  }
}
