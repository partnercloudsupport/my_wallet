import 'package:my_wallet/ui/account/list/data/list_accounts_repository.dart';
import 'package:my_wallet/database/data.dart';

class ListAccountsUseCase {
  final ListAccountsRepository _repo = ListAccountsRepository();

  Future<List<Account>> loadAllAccounts() {
    return _repo.loadAllAccounts();
  }

  Future<bool> deleteAccount(Account acc) {
    return _repo.deleteAccount(acc);
  }
}