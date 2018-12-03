import 'package:my_wallet/ui/home/monthydetail/data/monthly_detail_repository.dart';
import 'package:my_wallet/ui/home/monthydetail/data/monthly_detail_entity.dart';

class HomeMonthlyDetailUseCase {
  final HomeMonthlyDetailRepository _repo = HomeMonthlyDetailRepository();

  Future<HomeMonthlyDetailEntity> loadData() {
    return _repo.loadData();
  }
}