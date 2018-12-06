import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';

abstract class ExpenseDataView extends DataView {
  void onExpensesDetailLoaded(List<ExpenseEntity> value);
}