import 'package:my_wallet/ui/user/login/domain/login_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/user/login/presentation/view/login_data_view.dart';

class LoginPresenter extends CleanArchitecturePresenter<LoginUseCase, LoginDataView> {
  LoginPresenter() : super(LoginUseCase());

  void signIn(String email, String password) {
    useCase.signIn(email, password, dataView.onSignInSuccess, dataView.onSignInFailed);
  }

  void checkUserHome() {
    useCase.checkUserHome(dataView.onUserHomeResult);
  }
}