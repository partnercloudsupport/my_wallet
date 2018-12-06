import 'package:my_wallet/ui/home/main/data/main_home_entity.dart';
import 'package:my_wallet/database/database_manager.dart' as _db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/database/data.dart';

class HomeRepository {
  final _HomeDatabaseRepository _dbRepo = _HomeDatabaseRepository();
  Future<List<HomeEntity>> loadHome() {
    return _dbRepo.loadHome();
  }
}

class _HomeDatabaseRepository {
  Future<List<HomeEntity>> loadHome() async {
    List<AppCategory> cats = await _db.queryCategoryWithTransaction(from: Utils.firstMomentOfMonth(DateTime.now()), to: Utils.lastDayOfMonth(DateTime.now()), filterZero: false);

    List<HomeEntity> homeEntities = cats == null ? [] : cats.map((f) => HomeEntity(f.id, f.name, f.balance, f.colorHex)).toList();

    return homeEntities;
  }
}