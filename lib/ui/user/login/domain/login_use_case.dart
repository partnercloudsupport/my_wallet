import 'package:my_wallet/ui/user/login/data/login_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class LoginUseCase extends CleanArchitectureUseCase<LoginRepository>{
  LoginUseCase() : super(LoginRepository());

  void signIn(email, password, onNext<bool> onNext, onError onError) {
    execute(Future(() async {
      var result = false;
      do {
        await repo.validateEmail(email);
        await repo.validatePassword(password);

        User user = await repo.signinToFirebase(email, password);

        if (user == null) break;

        await repo.saveUserReference(user.uuid);

        result = (user.displayName != null && user.displayName.isNotEmpty);
      } while(false);
      return result;
    }), onNext, error: (e) => handleError(onError, e));
  }

  void checkUserHome(onNext<bool> next, onError onError) {
    execute(Future(() async {
      var result = false;
      do {
        // if this user is a host, allow him to go directly into his home. 1 host cannot host more than 1 home
        User user = await repo.getCurrentUser();
        bool isHost = await repo.checkHost(user);

        if (isHost) {
          Home home = await repo.getHome(user.email);

          // save his home to shared pref
          await repo.saveHome(home);

          user = await repo.getUserDetailFromFbDatabase(user.uuid, user);

          // switch database reference
          await repo.switchReference(user.uuid);

          await repo.saveUser(user);

          next(true);

          break;
        }

        result = await repo.checkUserHome();
      } while (false);

      return result;
    }), next, error: (e) => handleError(onError, e));
  }

  void handleError(onError onError, dynamic e) {
    if( e is Exception) {
      onError(e);
    } else {
      onError(LoginException(e.toString()));
    }
  }

  void signInWithGoogle(onNext<bool> next, onError error) {
    execute(Future(() async {
      var result = false;
      do {
        User user = await repo.signInWithGoogle();

        if (user == null) break;

        await repo.saveUserReference(user.uuid);

        result = (user.displayName != null && user.displayName.isNotEmpty);

        return result;
      } while (false);
    }), next, error: (e) => handleError(error, e));
  }

  void signInWithFacebook(onNext<bool> next, onError error) {
    execute(Future(() async {
      var result = false;
      do {
        User user = await repo.signInWithFacebook();

        if(user == null) break;

        await repo.saveUserReference(user.uuid);

        result = (user.displayName != null && user.displayName.isNotEmpty);
      } while(false);

      return result;
    }), next, error: (e) => handleError(error, e));
  }
}