import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/homeprofile/presentation/presenter/homeprofile_presenter.dart';
import 'package:my_wallet/ui/user/homeprofile/presentation/view/homeprofile_data_view.dart';

class HomeProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeProfileState();
  }
}

class _HomeProfileState extends CleanArchitectureView<HomeProfile, HomeProfilePresenter> implements HomeProfileDataView {

  _HomeProfileState() : super(HomeProfilePresenter());

  final TextEditingController _hostEmailController = TextEditingController();
  final TextEditingController _homeNameController = TextEditingController();
  final GlobalKey<RoundedButtonState> _joinHomeState = GlobalKey();
  final GlobalKey<RoundedButtonState> _createHomeState = GlobalKey();

  bool creatingHome = false;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Set up your home profile",
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppTheme.white
        ),
        padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(20.0),
      child: ListView(
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
              style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.black),
            ),
          ),
          RoundedButton(
            key: _joinHomeState,
            onPressed: () {},
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
              style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.black),
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
      ),
    );
  }

  void _createProfile() {
    if (creatingHome) return;

    creatingHome = true;
    _createHomeState.currentState.process();

    presenter.createHomeProfile(_homeNameController.text);
  }

  @override
  void onHomeCreated(bool result) {
    creatingHome = false;
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
}