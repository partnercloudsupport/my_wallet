import 'package:my_wallet/ui/user/login/data/login_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class LoginUseCase extends CleanArchitectureUseCase<LoginRepository>{
  LoginUseCase() : super(LoginRepository());

  void signIn(email, password, onNext<bool> onNext, onError onError) async {
    try {
      do {

        await repo.validateEmail(email);
        await repo.validatePassword(password);

        User user = await repo.signinToFirebase(email, password);

        if(user == null) break;

        await repo.saveUserReference(user.uuid);

        // if this user is a host, allow him to go directly into his home. 1 host cannot host more than 1 home
        bool isHost = await repo.checkHost(user);

        print("check host $isHost");
        
        if(isHost) {
          // save his home to shared pref
          await repo.saveHome(user.uuid);
        }
        onNext(true);
      } while(false);
    } catch (e) {
      onError(e);
    }
  }

  void checkUserHome(onNext<bool> next) {
    repo.checkUserHome().then((result) => next(result));
  }
}