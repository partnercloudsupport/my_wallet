import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/splash/data/splash_entity.dart';
export 'package:my_wallet/ui/splash/data/splash_entity.dart';

abstract class SplashDataView extends DataView {
  void onAppDataLoaded(AppDetail detail);

  void onAppLoadingError(Exception e);

  void updateVersion(String version);
}