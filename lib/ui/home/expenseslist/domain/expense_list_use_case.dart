import 'package:my_wallet/ui/home/expenseslist/data/expense_list_repository.dart';
import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';

class ExpenseRepositoryUseCase {

  final ExpenseRepository _repo = ExpenseRepository();

  Future<List<ExpenseEntity>> loadExpense() {
  return _repo.loadExpense();
  }
  }