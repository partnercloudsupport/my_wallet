import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/user/detail/data/detail_repository.dart';

import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailUseCase extends CleanArchitectureUseCase<UserDetailRepository> {
  UserDetailUseCase() : super(UserDetailRepository());

  void loadCurrentUser(onNext<UserDetailEntity> next) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String uuid = sharedPreferences.get(UserUUID);

    UserDetailEntity user = await repo.loadUserWithUuid(uuid);

    next(user);
  }
}