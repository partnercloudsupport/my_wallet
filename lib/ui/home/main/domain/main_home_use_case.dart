import 'package:my_wallet/ui/home/main/data/main_home_repository.dart';
import 'package:my_wallet/ui/home/main/data/main_home_entity.dart';

class HomeRepositoryUseCase {

  final HomeRepository _repo = HomeRepository();

  Future<List<HomeEntity>> loadHome() {
  return _repo.loadHome();
  }
  }