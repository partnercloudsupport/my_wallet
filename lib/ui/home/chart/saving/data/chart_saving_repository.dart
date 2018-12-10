import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/database/database_manager.dart' as _db;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

class SavingChartRepository extends CleanArchitectureRepository {
  Future<SavingEntity> loadSaving() async {
    var start = Utils.firstMomentOfMonth(DateTime.now());
    var today = DateTime.now();


    var incomeThisMonth = await _db.sumAllTransactionBetweenDateByType(start, today, TransactionType.typeIncome);
    var expenseThisMonth = await _db.sumAllTransactionBetweenDateByType(start, today, TransactionType.typeExpense);

    var monthlySaving = incomeThisMonth - expenseThisMonth;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var targetSaving = sharedPreferences.get(keyTargetSaving) ?? 0.0;

    return SavingEntity(monthlySaving, monthlySaving > 0 ? targetSaving > 0 ? monthlySaving/targetSaving : 1.0 : 0.0);
  }
}