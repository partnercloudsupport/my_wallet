import 'package:my_wallet/ui/home/chart/saving/domain/chart_saving_use_case.dart';
import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';

class SavingChartPresenter {
  final SavingChartUseCase _useCase = SavingChartUseCase();

  Future<SavingEntity> loadSaving() {
    return _useCase.loadSaving();
  }
}