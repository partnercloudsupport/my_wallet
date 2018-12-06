import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_repository.dart';

class SavingChartUseCase {
  final SavingChartRepository _repo = SavingChartRepository();

  Future<SavingEntity> loadSaving() {
    return _repo.loadSaving();
  }
}