import 'package:my_wallet/ui/home/overview/data/overview_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class HomeOverviewUseCase extends CleanArchitectureUseCase<HomeOverviewRepository>{
  HomeOverviewUseCase() : super(HomeOverviewRepository());

  void loadTotal(onNext<double> next) {
    repo.loadTotal().then(next);
  }
}