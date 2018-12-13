import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class HomeProfileDataView extends DataView {
  void onHomeCreated(bool result);
  void onHomeCreateFailed(Exception e);
}