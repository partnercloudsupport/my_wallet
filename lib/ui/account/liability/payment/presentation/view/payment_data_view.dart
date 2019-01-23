import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
export 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/data.dart';

abstract class PayLiabilityDataView extends DataView {
  void onAccountListLoaded(List<Account> accounts);
  void onAccountLoadFailed(Exception e);

  void onCategoryLoaded(List<AppCategory> categories);
  void onCategoryLoadFailed(Exception e);

  void onSaveSuccess(bool result);
  void onSaveFailed(Exception e);
}