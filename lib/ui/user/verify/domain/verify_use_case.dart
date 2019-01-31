import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/verify/data/verify_repository.dart';

class RequestValidationUseCase extends CleanArchitectureUseCase<RequestValidationRepository> {
  RequestValidationUseCase() : super(RequestValidationRepository());

  void requestValidationEmail(onNext<bool> next) {
    execute(repo.requestValidationEmail(), next, (e) {});
  }

  void signOut(onNext<bool> next,) {
    execute(Future(() async {
      // first, sign out from firebase
      bool signOut = await repo.signOut();

      if (signOut) {
        await repo.clearAllPreference();
        await repo.deleteDatabase();
        await repo.unlinkFbDatabase();
      }

//    repo.signOut().then((_) => next(true)).catchError((e) => err(e));
      await repo.signOut();

      return true;
    }), next, (e) {});
  }

  void checkUserValidation(onNext<bool> next) {
    execute(Future(() async {
      var currentUser = await repo.currentUser();

      return currentUser != null && currentUser.isVerified;
    }), next, (e) {});
  }
}