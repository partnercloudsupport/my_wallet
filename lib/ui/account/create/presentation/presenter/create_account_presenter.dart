import 'package:my_wallet/ui/account/create/domain/create_account_use_case.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_dataview.dart';

class CreateAccountPresenter extends CleanArchitecturePresenter<CreateAccountUseCase, CreateAccountDataView>{
  CreateAccountPresenter() : super(CreateAccountUseCase());

  void saveAccount(
      AccountType type,
      String name,
      double amount) {
    useCase.saveAccount(type, name, amount, dataView.onAccountSaved, dataView.onError);
  }
}