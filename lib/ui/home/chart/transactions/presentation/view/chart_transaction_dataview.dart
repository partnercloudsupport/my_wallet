import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home/chart/transactions/data/transaction_entity.dart';

abstract class TransactionDataView extends DataView {
  void onTransactionListLoaded(List<TransactionEntity> list);
}