import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class CreateCategoryDataView extends DataView {
  void onCreateCategorySuccess(int categoryId);
  void onCreateCategoryError(Exception e);
}