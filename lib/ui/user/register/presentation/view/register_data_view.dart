import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class RegisterDataView extends DataView {
  void onRegisterSuccess(bool result);
  void onRegisterFailed(Exception e);
}