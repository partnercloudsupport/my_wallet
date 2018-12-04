import 'package:my_wallet/ui/home/chart/income/domain/chart_income_use_case.dart';
import 'package:my_wallet/ui/home/chart/income/data/income_entity.dart';

class ChartIncomePresenter {
  final ChartIncomeUseCase _useCase = ChartIncomeUseCase();

  Future<List<IncomeEntity>> loadIncome() {
    return _useCase.loadIncome();
  }
}