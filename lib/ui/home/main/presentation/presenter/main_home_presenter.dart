import 'package:my_wallet/ui/home/main/domain/main_home_use_case.dart';
import 'package:my_wallet/ui/home/main/data/main_home_entity.dart';

class HomePresenter {
  final HomeRepositoryUseCase _useCase = HomeRepositoryUseCase();

  Future<List<HomeEntity>> loadHome() {
    return _useCase.loadHome();
  }
}