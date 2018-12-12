import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/home/drawer/domain/drawer_use_case.dart';
import 'package:my_wallet/ui/home/drawer/presentation/view/drawer_data_view.dart';

class LeftDrawerPresenter extends CleanArchitecturePresenter<LeftDrawerUseCase, LeftDrawerDataView> {
  LeftDrawerPresenter() : super(LeftDrawerUseCase());

  void signOut() {
    useCase.signOut(dataView.onSignOutSuccess, dataView.onSignOutFailed);
  }
}