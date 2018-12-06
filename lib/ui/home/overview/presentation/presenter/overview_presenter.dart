import 'package:my_wallet/ui/home/overview/domain/overview_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/home/overview/presentation/view/overview_callback.dart';

class HomeOverviewPresenter extends CleanArchitecturePresenter<HomeOverviewUseCase, OverviewDataView> {
  HomeOverviewPresenter() : super(HomeOverviewUseCase());

  void loadTotal() {
    useCase.loadTotal(dataView.onLoadTotalSuccess);
  }
}