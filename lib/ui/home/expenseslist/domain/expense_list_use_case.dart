import 'package:my_wallet/ui/home/expenseslist/data/expense_list_repository.dart';
import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class ExpenseUseCase extends CleanArchitectureUseCase<ExpenseRepository>{

  ExpenseUseCase() : super(ExpenseRepository());

  void loadExpense(onNext<List<ExpenseEntity>> next) {
    repo.loadExpense().then((value) => next(value));
  }
}