import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';
import 'package:my_wallet/ui/home/chart/title/domain/chart_title_use_case.dart';

class ChartTitlePresenter {
  final ChartTitleUseCase _useCase = ChartTitleUseCase();

  Future<ChartTitleEntity> loadTitleDetail() {
    return _useCase.loadTitleDetail();
  }
}