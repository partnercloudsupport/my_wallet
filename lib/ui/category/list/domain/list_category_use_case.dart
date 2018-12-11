import 'package:my_wallet/ui/category/list/data/list_category_repository.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class ListCategoryUseCase extends CleanArchitectureUseCase<CategoryListRepository>{
  ListCategoryUseCase() : super(CategoryListRepository());

  void loadCategories(onNext<List<AppCategory>> next) {
    repo.loadCategories().then((result) => next(result));
  }
}