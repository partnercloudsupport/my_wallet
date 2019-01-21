import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/account/transfer/data/transfer_entity.dart';
export 'package:my_wallet/ui/account/transfer/data/transfer_entity.dart';

abstract class AccountTransferDataView extends DataView {
  void onAccountListUpdated(TransferEntity entity);
  void onAccountListQueryFailed(Exception e);

  void onAccountTransferSuccess(bool result);
  void onAccountTransferFailed(Exception e);
}