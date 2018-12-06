import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';
import 'package:my_wallet/ui/home/chart/title/data/chart_title_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class ChartTitleUseCase extends CleanArchitectureUseCase<ChartTitleRepository>{
  ChartTitleUseCase() : super(ChartTitleRepository());

  void loadTitleDetail(onNext<ChartTitleEntity> next) {
    repo.loadTitleDetail().then((value) => next(value));
}
}