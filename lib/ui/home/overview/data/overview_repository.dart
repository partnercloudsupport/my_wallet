import 'package:my_wallet/database/database_manager.dart' as _db;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

class HomeOverviewRepository extends CleanArchitectureRepository {
  final _HomeOverviewDatabaseRepository _dbRepo = _HomeOverviewDatabaseRepository();

  Future<double> loadTotal() {
    return _dbRepo.loadTotal();
  }

}

class _HomeOverviewDatabaseRepository {
  Future<double> loadTotal() async {
    return await _db.sumAllAccountBalance(types: [
      AccountType.paymentAccount,
      AccountType.credit,
      AccountType.assets
    ]) - await _db.sumAllAccountBalance(types: [AccountType.liability]);
  }
}