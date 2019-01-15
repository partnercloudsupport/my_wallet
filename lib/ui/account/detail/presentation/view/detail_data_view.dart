import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

abstract class AccountDetailDataView extends DataView {
  void onAccountLoaded(Account account);
  void failedToLoadAccount(Exception ex);
}