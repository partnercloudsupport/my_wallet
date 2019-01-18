import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/splash/presentation/view/splash_data_view.dart';
import 'package:my_wallet/ui/splash/presentation/presenter/splash_presenter.dart';

class SplashView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashViewState();
  }
}

class _SplashViewState extends CleanArchitectureView<SplashView, SplashPresenter> implements SplashDataView {
  _SplashViewState() : super(SplashPresenter());

  var _error;
  var _version;

  get _isError => _error != null;

  GlobalKey<ErrorPageState> _errorKey = GlobalKey();

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    presenter.loadAppVersion();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      body: Stack(
        children: <Widget>[
          _isError ? ErrorPage(_errorKey, "Error happens while starting the app. Please try again later", loadData) : Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/nartus.png", fit: BoxFit.fitWidth, scale: 0.8,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Loading data...",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.darkBlue),
              ),
            ),
          ],
        ),
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.bottomCenter,
            child: Text(_version == null ? "" : _version, style: TextStyle(color: AppTheme.darkBlue),),
          )
        ]
      )
    );
  }

  @override
  void onAppDataLoaded(AppDetail detail) {
    if(_errorKey.currentContext != null) {
      _errorKey.currentState.stopRetry();
    }
    String routeName;
    do {
      if (detail == null) {
        routeName = routes.Login;
        break;
      }
      if (!detail.hasUser) {
        routeName = routes.Login;
        break;
      }

      if (!detail.hasProfile) {
        routeName = routes.HomeProfile;
        break;
      }

      routeName = routes.MyHome;
    } while (false);

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  void onAppLoadingError(Exception e) {
    if(_errorKey.currentContext != null) {
      _errorKey.currentState.stopRetry();
    }

    setState(() => _error = e.toString());
  }

  void loadData() {
    presenter.loadAppData();
  }

  void updateVersion(String version) {
    setState(() => _version = version);
  }
}
