import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class ListAccountDataView extends DataView {
  void onAccountListLoaded(List<Account> acc);
}