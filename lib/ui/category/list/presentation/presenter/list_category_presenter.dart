import 'package:my_wallet/ui/category/list/domain/list_category_use_case.dart';
import 'package:my_wallet/database/data.dart';

class ListCategoryPresenter {
  final ListCategoryUseCase _useCase = ListCategoryUseCase();

  Future<List<AppCategory>> loadCategories() {
    return _useCase.loadCategories();
  }
}