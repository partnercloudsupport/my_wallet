import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class LoginDataView extends DataView {
  void onSignInSuccess(bool result);
  void onSignInFailed(Exception e);

  void onUserHomeResult(bool exist);
  void onUserHomeFailed(Exception e);
}