import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/ui/category/create/domain/create_category_exception.dart';
import 'dart:math';
import 'package:my_wallet/data/firebase/database.dart' as fm;
import 'package:my_wallet/ca/data/ca_repository.dart';

class CreateCategoryRepository extends CleanArchitectureRepository {
  final _CreateCategoryDatabaseRepository _dbRepo = _CreateCategoryDatabaseRepository();
  final _CreateCategoryFirebaseRepository _fbRepo = _CreateCategoryFirebaseRepository();

  Future<int> generateId() {
    return _dbRepo.generateId();
  }

  Future<String> generateRandomColor() {
    return _dbRepo._generateRandomColor();
  }

  Future<bool> saveCategory(int id, String name, String color) {
    return _fbRepo.saveCategory(id, name, color);
  }

  Future<bool> validateName(String name) async {
    return _dbRepo.validateName(name);
  }
}

class _CreateCategoryDatabaseRepository {

  Future<bool> validateName(String name) async {
    return name == null || name.isEmpty ? throw CreateCategoryException("Please enter Category name") : true;
  }

  Future<int> generateId() {
    return db.generateCategoryId();
  }

  Future<String> _generateRandomColor() async {
    Random rnd = Random();
    var hex = "0123456789abcdef";

    var color = "#";
    for(int i = 0; i < 6; i++) {
      color += String.fromCharCode(hex.codeUnitAt(rnd.nextInt(hex.length)));
    }

    return color;
  }
}

class _CreateCategoryFirebaseRepository {
  Future<bool> saveCategory(int id, String name, String color) {
    return fm.addCategory(AppCategory(id, name, color, 0.0));
  }
}
