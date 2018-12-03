import 'package:my_wallet/ui/home/chart/data/chart_row_repository.dart';
import 'package:my_wallet/ui/home/chart/data/chart_entity.dart';

class ChartUseCase {
  ChartRepository _repo = ChartRepository();

  Future<ChartEntity> loadChartData() {
    return _repo.loadChartData();
  }
}