import 'package:my_wallet/ui/home/chart/title/domain/chart_title_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/home/chart/title/presentation/view/chart_title_data_view.dart';

class ChartTitlePresenter extends CleanArchitecturePresenter<ChartTitleUseCase, ChartTitleDataView>{
  ChartTitlePresenter() : super(ChartTitleUseCase());

  void loadTitleDetail() {
    return useCase.loadTitleDetail(dataView.onDetailLoaded);
  }
}