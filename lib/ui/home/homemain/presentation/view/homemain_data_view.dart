export 'package:my_wallet/ui/home/homemain/data/homemain_expenses_entity.dart';
import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home/homemain/data/homemain_expenses_entity.dart';

abstract class MyWalletHomeDataView extends DataView {
  void onExpensesDetailLoaded(List<ExpenseEntity> value);
}