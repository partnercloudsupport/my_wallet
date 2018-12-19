import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/homeprofile/gohome/presentation/presenter/gohome_presenter.dart';
import 'package:my_wallet/ui/user/homeprofile/gohome/presentation/view/gohome_data_view.dart';

class GoHome extends StatefulWidget {
  final String homeKey;
  final String homeName;
  final String hostEmail;

  GoHome(this.homeKey, this.homeName, this.hostEmail);

  @override
  State<StatefulWidget> createState() {
    return _GoHomeState();
  }
}

class _GoHomeState extends CleanArchitectureView<GoHome, GoHomePresenter> implements GoHomeDataView {
  _GoHomeState() : super(GoHomePresenter());

  GlobalKey<RoundedButtonState> _goHomeState = GlobalKey();

  bool _goingHome = false;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme.apply(displayColor: AppTheme.darkBlue, bodyColor: AppTheme.darkBlue);
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(30.0),
            child: Text("Found your home", style: theme.headline,),),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            child: Text(widget.homeName, style: theme.headline.apply(fontSizeFactor: 0.9, color: AppTheme.pinkAccent)),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            child: Text("and host is", style: theme.title,),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            child: Text(widget.hostEmail, style: theme.title.apply(fontSizeFactor: 1.2, color: AppTheme.pinkAccent),),
          ),
          RoundedButton(
            key: _goHomeState,
            onPressed: _goHome,
            child: Text("Go Home"),
            color: AppTheme.darkBlue,
          )
        ],
      ),
    );
  }

  void _goHome() {
    if(_goingHome) return;

    _goingHome = true;
    _goHomeState.currentState.process();

    presenter.goHome(widget.homeKey, widget.homeName, widget.hostEmail);
  }

  @override
  void onHomeSetupDone(bool result) {
    Navigator.pushReplacementNamed(context, routes.MyHome);
  }

}