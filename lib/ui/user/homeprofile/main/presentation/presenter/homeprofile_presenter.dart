import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/user/homeprofile/main/domain/homeprofile_use_case.dart';
import 'package:my_wallet/ui/user/homeprofile/main/presentation/view/homeprofile_data_view.dart';

class HomeProfilePresenter extends CleanArchitecturePresenter<HomeProfileUseCase, HomeProfileDataView> {
  HomeProfilePresenter() : super(HomeProfileUseCase());

  void findUserHome() {
    return useCase.findUserHome(dataView.onHomeResult);
  }
}