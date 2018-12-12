import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/home/drawer/data/drawer_repository.dart';

class LeftDrawerUseCase extends CleanArchitectureUseCase<LeftDrawerRepository> {
  LeftDrawerUseCase() : super(LeftDrawerRepository());

  void signOut(onNext<bool> next, onError err) {
    repo.signOut().then((_) => next(true)).catchError((e) => err(e));
  }
}