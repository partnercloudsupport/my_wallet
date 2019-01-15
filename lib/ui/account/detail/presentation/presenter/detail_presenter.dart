import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/account/detail/domain/detail_use_case.dart';
import 'package:my_wallet/ui/account/detail/presentation/view/detail_data_view.dart';

class AccountDetailPresenter extends CleanArchitecturePresenter<AccountDetailUseCase, AccountDetailDataView> {
  AccountDetailPresenter() : super(AccountDetailUseCase());

  void loadAccount(int accountId) {
    useCase.loadAccount(accountId, dataView.onAccountLoaded, dataView.failedToLoadAccount);
  }
}