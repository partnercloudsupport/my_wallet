import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/budget/list/domain/list_use_case.dart';
import 'package:my_wallet/ui/budget/list/presentation/view/list_data_view.dart';

class ListBudgetsPresenter extends CleanArchitecturePresenter<ListBudgetsUseCase, ListBudgetsDataView> {
  ListBudgetsPresenter() : super(ListBudgetsUseCase());

  void loadThisMonthBudgetList() {
    useCase.loadThisMonthBudgetList(dataView.onBudgetLoaded);
  }
}