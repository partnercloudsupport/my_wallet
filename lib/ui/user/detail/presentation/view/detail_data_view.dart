import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/user/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/user/detail/data/detail_entity.dart';

abstract class UserDetailDataView extends DataView {
  void onUserLoaded(UserDetailEntity user);
}