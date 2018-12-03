import 'package:my_wallet/ui/home/expenses/data/expenses_repository.dart';
import 'package:my_wallet/ui/home/expenses/data/expenses_entity.dart';

class ExpensesRepositoryUseCase {
  final ExpensesRepository _repo = ExpensesRepository();

  Future<List<ExpeneseEntity>> loadExpenses() {
    return _repo.loadExpenses();
  }
}