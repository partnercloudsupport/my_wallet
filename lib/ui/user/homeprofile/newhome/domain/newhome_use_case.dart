import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/homeprofile/newhome/data/newhome_repository.dart';

class NewHomeUseCase extends CleanArchitectureUseCase<NewHomeRepository> {
  NewHomeUseCase() : super(NewHomeRepository());

  void createHomeProfile(String name, onNext<bool> next, onError err) async {
    try {
      // get user to be key of the host of new home
      User host = await repo.getCurrentUser();

      // create this data reference on Firebase database
      String homeKey = await repo.createHome(host, name);

      if(homeKey == null) throw NewHomeException("Failed to create this new home");

      // save this key to shared preference
      await repo.saveHome(homeKey, name, host.email);

      await repo.updateDatabaseReference(homeKey);

      await repo.saveUserToHome(host);

      next(true);
    } catch (e) {
      print(e);
      err(e);
    }
  }

  void joinHomeWithHost(String host, onNext<bool> onJoinSuccess, onError onJoinFailed) async {
    try {
      Home home = await repo.findHomeOfHost(host);

      if(home == null) throw NewHomeException("This host $host does not have any home right now");

      User myProfile = await repo.getCurrentUser();

      bool result = await repo.joinHome(home, myProfile);

      if(!result) throw NewHomeException("Failed to join home with $host");

      // save this home key
      await repo.saveHome(home.key, home.name, home.host);

      // and finally update database reference
      await repo.updateDatabaseReference(home.key);

      await repo.saveUserToHome(myProfile);

      onJoinSuccess(true);
    } catch(e) {
      onJoinFailed(e);
    }
  }
}