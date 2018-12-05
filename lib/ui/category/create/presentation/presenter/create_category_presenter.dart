import 'package:my_wallet/ui/category/create/domain/create_category_use_case.dart';
import 'package:my_wallet/database/data.dart';

class CreateCategoryPresenter {
  final CreateCategoryUseCase _useCase = CreateCategoryUseCase();

  Future<bool> saveCategory(String name) {
    return _useCase.saveCategory(name);
  }
}