import 'package:my_wallet/ui/home/expenses/domain/expenses_use_case.dart';
import 'package:my_wallet/ui/home/expenses/data/expenses_entity.dart';

class ExpensesRepositoryPresenter {
  final ExpensesRepositoryUseCase _useCase = ExpensesRepositoryUseCase();

  Future<List<ExpeneseEntity>> loadExpenses() {
    return _useCase.loadExpenses();
  }
}