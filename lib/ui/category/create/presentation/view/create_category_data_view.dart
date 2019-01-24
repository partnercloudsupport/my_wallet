import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

abstract class CreateCategoryDataView extends DataView {
  void onCreateCategorySuccess(int categoryId);
  void onCreateCategoryError(Exception e);

  void onCategoryDetailLoaded(AppCategory category);
}