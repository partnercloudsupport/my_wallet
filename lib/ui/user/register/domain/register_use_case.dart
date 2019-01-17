import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/register/data/register_repository.dart';

class RegisterUseCase extends CleanArchitectureUseCase<RegisterRepository> {
  RegisterUseCase() : super(RegisterRepository());

  void registerEmail(String displayName, String email, String password, onNext<bool> next, onError error) {
    execute(Future(() async {
      var result = false;
      do {
        if(!await repo.validateDisplayName(displayName)) break;

        if(!await repo.validateEmail(email)) break;

        if(!await repo.validatePassword(password)) break;

        if(!await repo.registerEmail(email, password, displayName)) break;

//        await repo.updateDisplayName(displayName);

        User user = await repo.getCurrentUser();
//        await repo.saveUser(user);

        await repo.saveUserReference(user.uuid);

        result = true;
      } while (false);

      return result;
    }), next, error: error);
  }
}