import 'package:my_wallet/ui/home/overview/domain/overview_use_case.dart';

class HomeOverviewPresenter {
  final HomeOverviewUseCase _useCase = HomeOverviewUseCase();

  Future<double> loadTotal() {
    return _useCase.loadTotal();
  }
}