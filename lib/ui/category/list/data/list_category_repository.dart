import 'package:my_wallet/database/database_manager.dart' as db;
import 'package:my_wallet/database/data.dart';

class CategoryListRepository {
  final _CategoryListDatabaseRepository _dbRepo = _CategoryListDatabaseRepository();

  Future<List<AppCategory>> loadCategories(TransactionType type) {
    return _dbRepo.loadCategories(type);
  }
}

class _CategoryListDatabaseRepository {
  Future<List<AppCategory>> loadCategories(TransactionType type) async {
    if (type == null) {
      return await db.queryCategory();
    }
    return await db.queryCategory(transactionType: type.index);
  }
}