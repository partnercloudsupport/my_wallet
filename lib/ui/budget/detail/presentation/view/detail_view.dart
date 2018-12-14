import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_data_view.dart';

class BudgetDetail extends StatefulWidget {
  final String title;

  BudgetDetail(this.title);

  @override
  State<StatefulWidget> createState() {
    return _BudgetDetailState();
  }
}

class _BudgetDetailState extends CleanArchitectureView<BudgetDetail, BudgetDetailPresenter> implements BudgetDetailDataView {
  _BudgetDetailState() : super(BudgetDetailPresenter());

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: widget.title,
      ),
      body: Column(

      ),
    );
  }
}