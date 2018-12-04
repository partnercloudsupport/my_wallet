import 'package:my_wallet/ui/home/chart/income/data/chart_income_repository.dart';
import 'package:my_wallet/ui/home/chart/income/data/income_entity.dart';

class ChartIncomeUseCase {
  final ChartIncomeRepository _repo = ChartIncomeRepository();

  Future<List<IncomeEntity>> loadIncome() {
    return _repo.loadIncome();
  }
}