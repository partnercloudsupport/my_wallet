import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;

class LiabilityRepository extends CleanArchitectureRepository {
  Future<Account> loadAccountInfo(int id) async {
    List<Account> accounts = await db.queryAccounts(id: id);

    if(accounts != null && accounts.length == 1) return accounts.first;

    throw Exception("Account id $id not found");
  }
}