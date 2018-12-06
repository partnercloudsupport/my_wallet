import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class SavingChartUseCase extends CleanArchitectureUseCase<SavingChartRepository>{
  SavingChartUseCase() : super(SavingChartRepository());

  void loadSaving(onNext<SavingEntity> next) {
    repo.loadSaving().then((entity) => next(entity));
  }
}