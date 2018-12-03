import 'package:my_wallet/ui/account/create/data/create_account_repository.dart';
import 'package:my_wallet/database/data.dart';

class CreateAccountUseCase {
  final CreateAccountRepository _repo = CreateAccountRepository();

  Future<bool> saveAccount(
      AccountType type,
      String name,
      double amount
      ) async {
    var result = false;

    do {
      if(!(await _repo.verifyType(type))) break;

      if (!(await _repo.verifyName(name))) break;

      int id = await _repo.generateAccountId();

      if (id < 0) break;

      result = await _repo.saveAccountToFirebase(id, name, amount, type);

    } while (false);

    return result;
  }
}