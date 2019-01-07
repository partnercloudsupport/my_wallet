import 'package:my_wallet/ui/home/chart/budget/domain/chart_budget_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/home/chart/budget/presentation/view/chart_budget_data_view.dart';

class ChartBudgetPresenter extends CleanArchitecturePresenter<ChartBudgetUseCase, ChartBudgetDataView>{
  ChartBudgetPresenter() : super(ChartBudgetUseCase());

  void loadSaving() {
    return useCase.loadSaving(dataView.onDataAvailable);
  }
}