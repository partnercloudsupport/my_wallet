import 'package:my_wallet/ui/home/chart/saving/domain/chart_saving_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/home/chart/saving/presentation/view/chart_saving_data_view.dart';

class SavingChartPresenter extends CleanArchitecturePresenter<SavingChartUseCase, ChartSavingDataView>{
  SavingChartPresenter() : super(SavingChartUseCase());

  void loadSaving() {
    return useCase.loadSaving(dataView.onDataAvailable);
  }
}