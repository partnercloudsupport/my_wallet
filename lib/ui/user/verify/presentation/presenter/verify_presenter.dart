import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/user/verify/presentation/view/verify_data_view.dart';
import 'package:my_wallet/ui/user/verify/domain/verify_use_case.dart';

class RequestValidationPresenter extends CleanArchitecturePresenter<RequestValidationUseCase, RequestValidationDataView> {
  RequestValidationPresenter() : super(RequestValidationUseCase());

  void requestValidationEmail() {
    useCase.requestValidationEmail(dataView.onRequestSent);
  }

  void signOut() {
    useCase.signOut(dataView.onSignOutSuccess);
  }

  void checkUserValidation() {
    useCase.checkUserValidation(dataView.onValidationResult);
  }
}