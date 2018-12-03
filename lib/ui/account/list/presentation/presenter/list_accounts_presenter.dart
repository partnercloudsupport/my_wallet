import 'package:my_wallet/ui/account/list/domain/list_accounts_use_case.dart';
import 'package:my_wallet/database/data.dart';

class ListAccountsPresenter {
  final ListAccountsUseCase _useCase = ListAccountsUseCase();

  Future<List<Account>> loadAllAccounts() {
    return _useCase.loadAllAccounts();
  }

  Future<bool> deleteAccount(Account acc) {
    return _useCase.deleteAccount(acc);
  }
}