import 'package:my_wallet/ui/category/list/data/list_category_repository.dart';
import 'package:my_wallet/database/data.dart';

class ListCategoryUseCase {
  final CategoryListRepository _repo = CategoryListRepository();

  Future<List<AppCategory>> loadCategories() {
    return _repo.loadCategories();
  }
}