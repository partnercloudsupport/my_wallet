import 'package:my_wallet/ui/category/create/domain/create_category_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_data_view.dart';

class CreateCategoryPresenter extends CleanArchitecturePresenter<CreateCategoryUseCase, CreateCategoryDataView>{
  CreateCategoryPresenter() : super(CreateCategoryUseCase());

  void saveCategory(int id, String name, CategoryType type) {
    return useCase.saveCategory(id, name, type, dataView.onCreateCategorySuccess, dataView.onCreateCategoryError);
  }

  void loadCategoryDetail(int id) {
    return useCase.loadCategoryDetail(id, dataView.onCategoryDetailLoaded);
  }
}