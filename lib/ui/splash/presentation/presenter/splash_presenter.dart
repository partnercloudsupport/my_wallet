import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/splash/domain/splash_use_case.dart';
import 'package:my_wallet/ui/splash/presentation/view/splash_data_view.dart';

class SplashPresenter extends CleanArchitecturePresenter<SplashUseCase, SplashDataView> {
  SplashPresenter() : super(SplashUseCase());

  void loadAppData() {
    useCase.loadAppData(dataView.onAppDataLoaded, dataView.onAppLoadingError);
  }

  void loadAppVersion() {
    useCase.loadAppVersion(dataView.updateVersion);
  }
}