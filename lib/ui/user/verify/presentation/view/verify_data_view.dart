import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class RequestValidationDataView extends DataView {
  void onRequestSent(bool result);

  void onSignOutSuccess(bool result);

  void onValidationResult(bool validated);
}