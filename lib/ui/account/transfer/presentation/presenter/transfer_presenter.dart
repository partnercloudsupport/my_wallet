import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/account/transfer/domain/transfer_use_case.dart';
import 'package:my_wallet/ui/account/transfer/presentation/view/transfer_data_view.dart';

class AccountTransferPresenter extends CleanArchitecturePresenter<AccountTransferUseCase, AccountTransferDataView> {
  AccountTransferPresenter() : super(AccountTransferUseCase());

  void loadAccountDetails(int fromAccountId) {
    useCase.loadAccountDetails(fromAccountId, dataView.onAccountListUpdated, dataView.onAccountListQueryFailed);
  }

  void transferAmount(Account fromAccount, Account toAccount, double amount) {
    useCase.transferAmount(fromAccount, toAccount, amount, dataView.onAccountTransferSuccess, dataView.onAccountTransferFailed);
  }
}