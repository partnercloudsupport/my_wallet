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

        if (user == null) break;

        await repo.saveUserReference(user.uuid);

        onNext(true);
      } while (false);
    } catch (e) {
      handleError(onError, e);
    }
  }

  void checkUserHome(onNext<bool> next, onError onError) async{
    try {
      do {
        // if this user is a host, allow him to go directly into his home. 1 host cannot host more than 1 home
        User user = await repo.getCurrentUser();
        bool isHost = await repo.checkHost(user);

        print("isHost $isHost");
        if (isHost) {
          // save his home to shared pref
          await repo.saveHome(user.uuid);

          print("save home done ${user.uuid} and $user");
          user = await repo.getUserDetailFromFbDatabase(user.uuid, user);
          print("user detail from Firebase database $user");

          // switch database reference
          await repo.switchReference(user.uuid);
          print("switched reference database");

          await repo.saveUser(user);
          print("save user, and return");

          next(true);

          break;
        }

        print("not host, check user home");
        repo.checkUserHome().then((result) => next(result));
      } while (false);
    } catch (e) {
      print(e.toString());
      handleError(onError, e);
    }
  }

  void handleError(onError onError, dynamic e) {
    if( e is Exception) {
      onError(e);
    } else {
      onError(LoginException(e.toString()));
    }
  }
}