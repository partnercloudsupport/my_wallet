import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/category/list/data/list_category_entity.dart';
export 'package:my_wallet/ui/category/list/data/list_category_entity.dart';

abstract class CategoryListDataView extends DataView {
  void onCategoriesLoaded(List<CategoryListItemEntity> value);
}