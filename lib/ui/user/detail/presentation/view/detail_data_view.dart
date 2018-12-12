import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/data/data.dart';

abstract class UserDetailDataView extends DataView {
  void onUserLoaded(User user);
}