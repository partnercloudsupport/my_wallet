import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

abstract class LiabilityDataView extends DataView {
  void onAccountLoaded(Account acc);
  void onAccountLoadError(Exception e);
}