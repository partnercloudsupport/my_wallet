import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class CreateAccountDataView extends DataView {
  void onAccountSaved(bool result);
  void onError(Exception e);
}