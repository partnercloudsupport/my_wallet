import 'package:my_wallet/ui/home/expenseslist/domain/expense_list_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/home/expenseslist/presentation/view/expese_list_dataview.dart';

class ExpensePresenter extends CleanArchitecturePresenter<ExpenseUseCase, ExpenseDataView>{
  ExpensePresenter() : super(ExpenseUseCase());

  void loadExpense() {
    return useCase.loadExpense(dataView.onExpensesDetailLoaded);
  }
}