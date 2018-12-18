import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/budget/detail/data/detail_entity.dart';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/budget/detail/data/detail_entity.dart';

abstract class BudgetDetailDataView extends DataView {
  void updateCategoryList(List<AppCategory> cats);

  void onSaveBudgetSuccess(bool result);
  void onSaveBudgetFailed(Exception e);

  void onBudgetLoaded(BudgetDetailEntity entity);
}