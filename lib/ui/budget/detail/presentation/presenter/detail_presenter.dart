import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/budget/detail/domain/detail_use_case.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_data_view.dart';

class BudgetDetailPresenter extends CleanArchitecturePresenter<BudgetDetailUseCase, BudgetDetailDataView> {
  BudgetDetailPresenter() : super(BudgetDetailUseCase());

  void loadCategoryBudget(int categoryId, DateTime from, DateTime to) {
    useCase.loadCategoryBudget(categoryId, from, to, dataView.onBudgetLoaded);
  }

  void saveBudget(
      AppCategory _cat,
      double _amount,
      DateTime startMonth,
      DateTime endMonth
      ) {
    useCase.saveBudget(_cat, _amount, startMonth, endMonth, dataView.onSaveBudgetSuccess, dataView.onSaveBudgetFailed);
  }
}