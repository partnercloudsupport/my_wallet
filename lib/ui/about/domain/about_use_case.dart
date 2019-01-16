import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/about/data/about_repository.dart';

class AboutUsUseCase extends CleanArchitectureUseCase<AboutUsRepository> {
  AboutUsUseCase() : super(AboutUsRepository());

  void loadData(onNext<AboutEntity> next) {
    repo.loadData().then((value) => next(value));
  }
}