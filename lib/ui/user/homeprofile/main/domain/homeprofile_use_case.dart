import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/homeprofile/main/data/homeprofile_repository.dart';

class HomeProfileUseCase extends CleanArchitectureUseCase<HomeProfileRepository> {
  HomeProfileUseCase() : super(HomeProfileRepository());

  void findUserHome(onNext<HomeEntity> next) async {
    execute(Future(() async {
      User user = await repo.getCurrentUser();

      HomeEntity entity = await repo.searchUserHome(user);

      return entity;
    }), next, (e) {
      debugPrint("Find user home error $e");
      next(null);
    });
  }
}