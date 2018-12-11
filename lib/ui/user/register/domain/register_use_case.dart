import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/register/data/register_repository.dart';

class RegisterUseCase extends CleanArchitectureUseCase<RegisterRepository> {
  RegisterUseCase() : super(RegisterRepository());

  void registerEmail(String displayName, String email, String password, onNext<bool> next, onError error) async {
    try {
      do {
        if(!await repo.validateDisplayName(displayName)) break;

        if(!await repo.validateEmail(email)) break;

        if(!await repo.validatePassword(password)) break;

        if(!await repo.registerEmail(email, password)) break;

        await repo.updateDisplayName(displayName);

        next(true);
      } while (false);
    } catch(e) {
      error(e);
    }
  }
}