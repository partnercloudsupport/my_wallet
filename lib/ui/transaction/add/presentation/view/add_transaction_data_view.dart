import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';

abstract class AddTransactionDataView extends DataView {
  void onAccountListLoaded(List<Account> value);
  void onCategoryListLoaded(List<AppCategory> value);

  void onSaveTransactionSuccess(bool result);
  void onSaveTransactionFailed(Exception e);

  void onLoadTransactionDetail(TransactionDetail detail);
  void onLoadTransactionFailed(Exception e);

  // on database update
  void updateUserDisplayName(UserDetail detail);
}