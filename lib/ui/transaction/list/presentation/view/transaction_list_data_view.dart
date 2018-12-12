import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/transaction/list/data/transaction_list_entity.dart';

abstract class TransactionListDataView extends DataView {
  void onTransactionListLoaded(List<TransactionEntity> value);
}