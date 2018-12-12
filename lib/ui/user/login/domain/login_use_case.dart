import 'package:my_wallet/ui/user/login/data/login_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:flutter/services.dart';

class LoginUseCase extends CleanArchitectureUseCase<LoginRepository>{
  LoginUseCase() : super(LoginRepository());

  void signIn(email, password, onNext<bool> onNext, onError onError) async {
    try {
      do {

        await repo.validateEmail(email);
        await repo.validatePassword(password);

        User user = await repo.signinToFirebase(email, password);

        if(user == null) break;

        await repo.saveUserToDatabase(user);

        await repo.saveUserReference(user.uuid);

        onNext(true);
      } while(false);
    } on PlatformException catch(e) {
      onError(e);
    }
  }
}