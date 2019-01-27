import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/homeprofile/newhome/presentation/view/newhome_data_view.dart';
import 'package:my_wallet/ui/user/homeprofile/newhome/presentation/presenter/newhome_presenter.dart';

class NewHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewHomeState();
  }
}

class _NewHomeState extends CleanArchitectureView<NewHome, NewHomePresenter> implements NewHomeDataView {
  _NewHomeState() : super(NewHomePresenter());

  final TextEditingController _hostEmailController = TextEditingController();
  final TextEditingController _homeNameController = TextEditingController();
  final GlobalKey<RoundedButtonState> _joinHomeState = GlobalKey();
  final GlobalKey<RoundedButtonState> _createHomeState = GlobalKey();

  bool _creatingHome = false;
  bool _joiningHome = false;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text("Join a home", style: Theme.of(context).textTheme.headline.apply(color: AppTheme.darkBlue)),
            margin: EdgeInsets.all(30.0),
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: AppTheme.darkBlue.withOpacity(0.2)
            ),
            child: TextField(
              controller: _hostEmailController,
              decoration: InputDecoration.collapsed(
                hintText: "Enter host's email address",
                hintStyle: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey),
              ),
              style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
            ),
          ),
          RoundedButton(
            key: _joinHomeState,
            onPressed: _joinAHome,
            child: Text("Request to join this home"),
            color: AppTheme.darkBlue,
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0,),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 1.0,
                    color: AppTheme.blueGrey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("OR", style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
                ),
                Expanded(
                  child: Container(
                    height: 1.0,
                    color: AppTheme.blueGrey,
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Create a new home", style: Theme.of(context).textTheme.headline.apply(color: AppTheme.darkBlue)),
            margin: EdgeInsets.all(30.0),
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: AppTheme.darkBlue.withOpacity(0.2)
            ),
            child: TextField(
              controller: _homeNameController,
              decoration: InputDecoration.collapsed(
                hintText: "Enter your home name",
                hintStyle: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey),
              ),
              style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
            ),
          ),
          RoundedButton(
            key: _createHomeState,
            onPressed: _createProfile,
            child: Text("Create home"),
            color: AppTheme.darkBlue,
          ),
        ],
      ),
    );
  }

  void _createProfile() {
    if (_creatingHome) return;

    _creatingHome = true;
    _createHomeState.currentState.process();

    presenter.createHomeProfile(_homeNameController.text);
  }

  @override
  void onHomeCreated(bool result) {
    _creatingHome = false;
    _createHomeState.currentState.stop();

    Navigator.pushReplacementNamed(context, routes.MyHome);
  }

  @override
  void onHomeCreateFailed(Exception e) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Failed to create home}"),
              content: Text("Your home ${_homeNameController.text} is not created because ${e.toString()}"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Try Again"),
                )
              ],
            )
    );
  }

  void _joinAHome() {
    if(_joiningHome) return;

    _joiningHome = true;
    _joinHomeState.currentState.process();
    presenter.joinHomeWithHost(_hostEmailController.text);
  }

  @override
  void onJoinSuccess(bool result) {
    _joiningHome = false;
    _joinHomeState.currentState.stop();

    Navigator.pushReplacementNamed(context, routes.MyHome);
  }

  @override
  void onJoinFailed(Exception e) {
    debugPrint(e.toString());
    _joiningHome = false;
    _joinHomeState.currentState.stop();

    showDialog(context: context,
    builder: (context) => AlertDialog(
      title: Text("Failed to join Home"),
      content: Text("Failed to join home of ${_hostEmailController.text} because ${e.toString()}"),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Try Again"),
        )
      ],
    ));
  }
}