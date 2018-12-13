import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/user/homeprofile/main/data/homeprofile_entity.dart';

export 'package:my_wallet/ui/user/homeprofile/main/data/homeprofile_entity.dart';

abstract class HomeProfileDataView extends DataView {
  void onHomeResult(HomeEntity entity);
}