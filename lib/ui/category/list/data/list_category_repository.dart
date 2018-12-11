import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/data/ca_repository.dart';

class CategoryListRepository extends CleanArchitectureRepository{

  final _CategoryListDatabaseRepository _dbRepo = _CategoryListDatabaseRepository();

  Future<List<AppCategory>> loadCategories() {
    return _dbRepo.loadCategories();
  }
}

class _CategoryListDatabaseRepository {
  Future<List<AppCategory>> loadCategories() async {
      return await db.queryCategory();
  }
}