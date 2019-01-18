import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/splash/data/splash_repository.dart';

class SplashUseCase extends CleanArchitectureUseCase<SplashRepository> {
  SplashUseCase() : super(SplashRepository());

  void loadAppData(onNext<AppDetail> next, onError error) {
    execute(repo.loadAppData(), next, error);
  }

  void loadAppVersion(onNext<String> next) {
    execute(repo.loadAppVersion(), next, (e) => next(""));
  }
}