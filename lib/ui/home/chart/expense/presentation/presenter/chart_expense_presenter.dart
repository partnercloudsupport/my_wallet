import 'package:my_wallet/ui/home/chart/expense/domain/chart_expense_use_case.dart';
import 'package:my_wallet/ui/home/chart/expense/data/expense_entity.dart';

class ChartExpensePresenter {
  final ChartExpenseUseCase _useCase = ChartExpenseUseCase();

  Future<List<ExpenseEntity>> loadExpense() {
    return _useCase.loadExpense();
  }
}