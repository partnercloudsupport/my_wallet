import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/budget/detail/domain/detail_use_case.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_data_view.dart';

class BudgetDetailPresenter extends CleanArchitecturePresenter<BudgetDetailUseCase, BudgetDetailDataView> {
  BudgetDetailPresenter() : super(BudgetDetailUseCase());

}