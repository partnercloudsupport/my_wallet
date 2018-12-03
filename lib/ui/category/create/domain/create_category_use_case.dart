import 'package:my_wallet/ui/category/create/data/create_category_repository.dart';
import 'package:my_wallet/database/data.dart';

class CreateCategoryUseCase {
  final CreateCategoryRepository _repo = CreateCategoryRepository();

  Future<bool> saveCategory(String name, TransactionType type) async {
    do {
      if(!(await _repo.validateName(name))) break;
      if(!(await _repo.validateType(type))) break;

      var color = await _repo.generateRandomColor();
      var id = await _repo.generateId();

      return _repo.saveCategory(id, name, type, color);
    } while(false);

    return false;
  }
}