import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/database/data.dart';

abstract class CategoryListDataView extends DataView {
  void onCategoriesLoaded(List<AppCategory> value);
}