import 'package:my_wallet/ui/home/monthydetail/domain/monthly_detail_use_case.dart';
import 'package:my_wallet/ui/home/monthydetail/data/monthly_detail_entity.dart';

class HomeMonthlyDetailPresenter {
  final HomeMonthlyDetailUseCase _useCase = HomeMonthlyDetailUseCase();

  Future<HomeMonthlyDetailEntity> loadData() {
    return _useCase.loadData();
  }
}