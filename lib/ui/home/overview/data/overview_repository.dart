import 'package:my_wallet/database/database_manager.dart' as _db;
import 'package:my_wallet/database/data.dart';

class HomeOverviewRepository {
  final _HomeOverviewDatabaseRepository _dbRepo = _HomeOverviewDatabaseRepository();

  Future<double> loadTotal() {
    return _dbRepo.loadTotal();
  }

}

class _HomeOverviewDatabaseRepository {
  Future<double> loadTotal() async {
    double total = 0.0;

    List<Account> accounts = await _db.queryAccounts();

    if (accounts != null && accounts.length > 0) {
      accounts.forEach((f) => total += f.balance);
    }

    return total;
  }
}