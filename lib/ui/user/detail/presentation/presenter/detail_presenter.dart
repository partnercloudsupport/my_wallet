import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/user/detail/domain/detail_use_case.dart';
import 'package:my_wallet/ui/user/detail/presentation/view/detail_data_view.dart';

class UserDetailPresenter extends CleanArchitecturePresenter<UserDetailUseCase, UserDetailDataView> {
  UserDetailPresenter() : super(UserDetailUseCase());

  void loadCurrentUser() {
    useCase.loadCurrentUser(dataView.onUserLoaded);
  }
}