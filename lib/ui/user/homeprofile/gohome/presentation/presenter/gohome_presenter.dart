import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/user/homeprofile/gohome/presentation/view/gohome_data_view.dart';
import 'package:my_wallet/ui/user/homeprofile/gohome/domain/gohome_use_case.dart';

class GoHomePresenter extends CleanArchitecturePresenter<GoHomeUseCase, GoHomeDataView> {
  GoHomePresenter() : super(GoHomeUseCase());

  void goHome(String homeKey) {
    useCase.goHome(homeKey, dataView.onHomeSetupDone);
  }
}