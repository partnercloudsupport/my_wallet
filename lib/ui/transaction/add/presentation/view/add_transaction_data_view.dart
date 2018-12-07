import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/database/data.dart';

export 'package:my_wallet/database/data.dart';

abstract class AddTransactionDataView extends DataView {
  void onAccountListLoaded(List<Account> value);
  void onCategoryListLoaded(List<AppCategory> value);

  void onSaveTransactionSuccess(bool result);
  void onSaveTransactionFailed(Exception e);
}