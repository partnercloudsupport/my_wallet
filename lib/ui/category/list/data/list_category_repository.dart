import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fb;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

class CategoryListRepository extends CleanArchitectureRepository{

  final _CategoryListDatabaseRepository _dbRepo = _CategoryListDatabaseRepository();
  final _CategoryListFirebaseRepository _fbRepo = _CategoryListFirebaseRepository();

  Future<List<AppCategory>> loadCategories() {
    return _dbRepo.loadCategories();
  }

  Future<bool> deleteCategory(AppCategory cat) {
    return _fbRepo.deleteCategory(cat);
  }
}

class _CategoryListDatabaseRepository {
  Future<List<AppCategory>> loadCategories() async {
      return await db.queryCategory();
  }
}

class _CategoryListFirebaseRepository {
  Future<bool> deleteCategory(AppCategory cat) {
    return fb.deleteCategory(cat);
  }
}