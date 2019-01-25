import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/account/liability/payment/domain/payment_use_case.dart';
import 'package:my_wallet/ui/account/liability/payment/presentation/view/payment_data_view.dart';

class PayLiabilityPresenter extends CleanArchitecturePresenter<PayLiabilityUseCase, PayLiabilityDataView> {
  PayLiabilityPresenter() : super(PayLiabilityUseCase());

  void loadAccounts(int exceptId) {
    useCase.loadAccounts(exceptId, dataView.onAccountListLoaded, dataView.onAccountLoadFailed);
  }

  void loadCategories(CategoryType type) {
    useCase.loadCategories(type, dataView.onCategoryLoaded, dataView.onCategoryLoadFailed);
  }

  void savePayment(int liabilityId, Account fromAccount, AppCategory category, double amount, DateTime date) {
    useCase.savePayment(liabilityId, fromAccount, category, amount, date, dataView.onSaveSuccess, dataView.onSaveFailed);
  }
}