import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
class AccountDetailRepository extends CleanArchitectureRepository {

  Future<Account> loadAccount(int accountId) async {
    var accounts = await db.queryAccounts(id: accountId);

    if(accounts != null && accounts.isNotEmpty) return accounts.first;

    throw Exception("Account with id $accountId not found");
  }
}