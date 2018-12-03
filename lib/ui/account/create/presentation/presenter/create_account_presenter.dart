import 'package:my_wallet/ui/account/create/domain/create_account_use_case.dart';
import 'package:my_wallet/database/data.dart';

class CreateAccountPresenter {
  final CreateAccountUseCase _useCase = CreateAccountUseCase();

  Future<bool> saveAccount(
      AccountType type,
      String name,
      double amount
      ) {
    return _useCase.saveAccount(type, name, amount);
  }
}