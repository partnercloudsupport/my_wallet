import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/homeprofile/gohome/data/gohome_repository.dart';

class GoHomeUseCase extends CleanArchitectureUseCase<GoHomeRepository> {
  GoHomeUseCase() : super(GoHomeRepository());

  void goHome(String homeKey, onNext<bool> next) async {
    await repo.updateHomeReference(homeKey);

    await repo.switchReference(homeKey);

    next(true);
  }
}