import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
export 'package:my_wallet/ui/budget/list/data/list_entity.dart';

abstract class ListBudgetsDataView extends DataView {
  void onBudgetLoaded(List<BudgetEntity> list);
}