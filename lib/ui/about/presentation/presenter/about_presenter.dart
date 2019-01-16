import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/about/domain/about_use_case.dart';
import 'package:my_wallet/ui/about/presentation/view/about_data_view.dart';

class AboutUsPresenter extends CleanArchitecturePresenter<AboutUsUseCase, AboutUsDataView> {
  AboutUsPresenter() : super(AboutUsUseCase());

  void loadData() {
    useCase.loadData(dataView.updateDetail);
  }
}