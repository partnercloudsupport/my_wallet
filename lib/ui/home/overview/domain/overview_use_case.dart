import 'package:my_wallet/ui/home/overview/data/overview_repository.dart';

class HomeOverviewUseCase {
  final HomeOverviewRepository _repo = HomeOverviewRepository();

  Future<double> loadTotal() {
    return _repo.loadTotal();
  }
}