import 'package:my_wallet/ui/category/list/domain/list_category_use_case.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/category/list/presentation/view/list_category_data_view.dart';

class ListCategoryPresenter extends CleanArchitecturePresenter<ListCategoryUseCase, CategoryListDataView>{
  ListCategoryPresenter() : super(ListCategoryUseCase());

  void loadCategories() {
    return useCase.loadCategories(dataView.onCategoriesLoaded);
  }

  void deleteCategory(int id) {
    useCase.deleteCategory(id);
  }
}