import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/user/homeprofile/newhome/domain/newhome_use_case.dart';
import 'package:my_wallet/ui/user/homeprofile/newhome/presentation/view/newhome_data_view.dart';

class NewHomePresenter extends CleanArchitecturePresenter<NewHomeUseCase, NewHomeDataView> {
  NewHomePresenter() : super(NewHomeUseCase());

  void createHomeProfile(String name) {
    useCase.createHomeProfile(name, dataView.onHomeCreated, dataView.onHomeCreateFailed);
  }
}