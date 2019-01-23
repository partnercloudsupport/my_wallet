import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/account/liability/detail/domain/liability_use_case.dart';
import 'package:my_wallet/ui/account/liability/detail/presentation/view/liability_data_view.dart';
export 'package:my_wallet/ui/account/liability/detail/presentation/view/liability_data_view.dart';

class LiabilityPresenter extends CleanArchitecturePresenter<LiabilityUseCase, LiabilityDataView> {
  LiabilityPresenter() : super(LiabilityUseCase());

  void loadAccountInfo(int id) {
    useCase.loadAccountInfo(id, dataView.onAccountLoaded, dataView.onAccountLoadError);
  }
}