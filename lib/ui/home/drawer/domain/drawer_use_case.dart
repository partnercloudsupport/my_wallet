import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/home/drawer/data/drawer_repository.dart';

class LeftDrawerUseCase extends CleanArchitectureUseCase<LeftDrawerRepository> {
  LeftDrawerUseCase() : super(LeftDrawerRepository());

  void signOut(onNext<bool> next, onError err) async {
    // first, sign out from firebase
    bool signOut = await repo.signOut();

    if (signOut) {
      await repo.clearAllPreference();
      await repo.deleteDatabase();
      await repo.unlinkFbDatabase();
    }

//    repo.signOut().then((_) => next(true)).catchError((e) => err(e));
    repo.signOut().then((_) => next(true));
  }
}