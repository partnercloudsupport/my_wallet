import 'package:my_wallet/ui/account/list/domain/list_accounts_use_case.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/account/list/presentation/view/list_account_dataview.dart';

class ListAccountsPresenter extends CleanArchitecturePresenter<ListAccountsUseCase, ListAccountDataView>{
  ListAccountsPresenter() : super(ListAccountsUseCase());

  void loadAllAccounts() {
    return useCase.loadAllAccounts(dataView.onAccountListLoaded);
  }

  void deleteAccount(Account acc) async {
    return useCase.deleteAccount(acc, (_) {});
  }
}