import 'package:my_wallet/ui/home/chart/expense/data/chart_expense_repository.dart';
import 'package:my_wallet/ui/home/chart/expense/data/expense_entity.dart';

class ChartExpenseUseCase {
  final ChartExpenseRepository _repo = ChartExpenseRepository();

  Future<List<ExpenseEntity>> loadExpense() {
    return _repo.loadExpense();
  }
}