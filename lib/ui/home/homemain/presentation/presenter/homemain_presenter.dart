import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/home/homemain/presentation/view/homemain_data_view.dart';
import 'package:my_wallet/ui/home/homemain/domain/homemain_use_case.dart';

class MyWalletHomePresenter extends CleanArchitecturePresenter<MyWalletHomeUseCase, MyWalletHomeDataView> {
  MyWalletHomePresenter() : super(MyWalletHomeUseCase());

  void loadExpense() {
    return useCase.loadExpense(dataView.onExpensesDetailLoaded);
  }
}