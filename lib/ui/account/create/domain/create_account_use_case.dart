import 'package:my_wallet/ui/account/create/data/create_account_repository.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class CreateAccountUseCase extends CleanArchitectureUseCase<CreateAccountRepository>{
  CreateAccountUseCase() : super(CreateAccountRepository());

  void saveAccount(
      AccountType type,
      String name,
      double amount,
      onNext<bool> next,
      onError error,
      ) async {
    var result = false;

    do {
      if(!(await repo.verifyType(type))) break;

      if (!(await repo.verifyName(name))) break;

      int id = await repo.generateAccountId();

      if (id < 0) break;

      result = await repo.saveAccountToFirebase(id, name, amount, type);

    } while (false);

    return next(result);
  }
}