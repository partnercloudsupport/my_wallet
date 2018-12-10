import 'package:my_wallet/ui/user/login/data/login_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class LoginUseCase extends CleanArchitectureUseCase<LoginRepository>{
  LoginUseCase() : super(LoginRepository());

  void signIn(email, password, onNext<bool> onNext, onError onError) async {
    try {
      do {

        if(!await repo.validateEmail(email)) break;
        if(!await repo.validatePassword(password)) break;

        User user = await repo.signinToFirebase(email, password);

        if(user == null) break;

        onNext(true);
      } while(false);
    } catch(e) {
      onError(e);
    }
  }
}