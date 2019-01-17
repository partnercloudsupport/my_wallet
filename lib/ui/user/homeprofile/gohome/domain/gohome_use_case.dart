import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/homeprofile/gohome/data/gohome_repository.dart';

class GoHomeUseCase extends CleanArchitectureUseCase<GoHomeRepository> {
  GoHomeUseCase() : super(GoHomeRepository());

  void goHome(String homeKey, String homeName, String hostEmail, onNext<bool> next) async {
    execute(Future(() async {
      await repo.updateHomeReference(homeKey, homeName, hostEmail);

      await repo.switchReference(homeKey);

      return true;
    }), next);
  }
}