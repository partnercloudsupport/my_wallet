import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/user/login/data/login_entity.dart';
export 'package:my_wallet/ui/user/login/data/login_entity.dart';

abstract class LoginDataView extends DataView {
  void onSignInSuccess(LoginResult result);
  void onSignInFailed(Exception e);

  void onUserHomeResult(bool exist);
  void onUserHomeFailed(Exception e);
}