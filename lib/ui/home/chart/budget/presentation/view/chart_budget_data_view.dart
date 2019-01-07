import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home/chart/budget/data/chart_budget_entity.dart';

abstract class ChartBudgetDataView extends DataView {
  void onDataAvailable(ChartBudgetEntity entity);
}