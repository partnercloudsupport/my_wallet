import 'package:my_wallet/ui/category/create/data/create_category_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/category/create/domain/create_category_exception.dart';

class CreateCategoryUseCase extends CleanArchitectureUseCase<CreateCategoryRepository>{
  CreateCategoryUseCase() : super(CreateCategoryRepository());

  void saveCategory(String name, onNext<int> next, onError error) async {
    execute<int>(Future(() async {
      bool validateName = await repo.validateName(name);

      if (!validateName) throw CreateCategoryException("Failed to validate name");
      var color = await repo.generateRandomColor();
      var id = await repo.generateId();

      await repo.saveCategory(id, name, color);

      return id;
    }), next, error);
  }
}