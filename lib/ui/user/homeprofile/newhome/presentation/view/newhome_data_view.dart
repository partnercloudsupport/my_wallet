import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class NewHomeDataView extends DataView {
  void onHomeCreated(bool result);
  void onHomeCreateFailed(Exception e);
}