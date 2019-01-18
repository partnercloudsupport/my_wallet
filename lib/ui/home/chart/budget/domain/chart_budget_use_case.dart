import 'package:my_wallet/ui/home/chart/budget/data/chart_budget_entity.dart';
import 'package:my_wallet/ui/home/chart/budget/data/chart_budget_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class ChartBudgetUseCase extends CleanArchitectureUseCase<ChartBudgetRepository>{
  ChartBudgetUseCase() : super(ChartBudgetRepository());

  void loadSaving(onNext<ChartBudgetEntity> next) {
    execute<ChartBudgetEntity>(repo.loadSaving(), next, (e) {
      print("Load saving error $e");
      next(ChartBudgetEntity(0.0, 0.0, 0.0));
    });
  }
}