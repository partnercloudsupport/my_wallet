import 'package:my_wallet/ui/home/chart/domain/chart_row_use_case.dart';
import 'package:my_wallet/ui/home/chart/data/chart_entity.dart';

class ChartPresenter {
  ChartUseCase _useCase = ChartUseCase();

  Future<ChartEntity> loadChartData() {
    return _useCase.loadChartData();
  }
}