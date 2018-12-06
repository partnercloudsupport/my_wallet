import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';
import 'package:my_wallet/ui/home/chart/title/data/chart_title_repository.dart';

class ChartTitleUseCase {
  final ChartTitleRepository _repo = ChartTitleRepository();

  Future<ChartTitleEntity> loadTitleDetail() {
    return _repo.loadTitleDetail();
}
}