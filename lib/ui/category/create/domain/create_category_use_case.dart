import 'package:my_wallet/ui/category/create/data/create_category_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/category/create/domain/create_category_exception.dart';

class CreateCategoryUseCase extends CleanArchitectureUseCase<CreateCategoryRepository>{
  CreateCategoryUseCase() : super(CreateCategoryRepository());

  void saveCategory(int currentId, String name, CategoryType type, onNext<int> next, onError error) async {
    execute<int>(Future(() async {
      bool validateName = await repo.validateName(name);

      if (!validateName) throw CreateCategoryException("Failed to validate name");
      if(currentId == null) {
        var id = await repo.generateId();

        var color = await repo.generateRandomColor();
        await repo.saveCategory(id, name, color, type);

        return id;
      } else {
        AppCategory category = await repo.loadCategory(currentId);
        await repo.updateCategory(category.id, name, category.colorHex, type);
      }
    }), next, error);
  }

  void loadCategoryDetail(int id, onNext<AppCategory> next) async {
    execute(repo.loadCategory(id), next, (e) {
      print("$e");
    });
  }
}