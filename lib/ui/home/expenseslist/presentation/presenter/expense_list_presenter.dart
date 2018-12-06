import 'package:my_wallet/ui/home/expenseslist/domain/expense_list_use_case.dart';
import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';

class ExpensePresenter {
  final ExpenseRepositoryUseCase _useCase = ExpenseRepositoryUseCase();

  Future<List<ExpenseEntity>> loadExpense() {
    return _useCase.loadExpense();
  }
}