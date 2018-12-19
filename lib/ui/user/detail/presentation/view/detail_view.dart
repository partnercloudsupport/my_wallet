import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/user/detail/presentation/view/detail_data_view.dart';

import 'package:my_wallet/data/data.dart';

class UserDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserDetailState();
  }
}

class _UserDetailState extends CleanArchitectureView<UserDetail, UserDetailPresenter> implements UserDetailDataView {
  _UserDetailState() : super(UserDetailPresenter());

  UserDetailEntity _user;

  @override
  init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    presenter.loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.height * 0.25;

    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Your Profile",
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SizedBox(
                height: iconSize,
                width: iconSize,
                child: CircleAvatar(
                  backgroundColor: _user == null || _user.color == null ? AppTheme.white : Color(_user.color),
                  child: _user != null
                      ? _user.photoUrl == null || _user.photoUrl.isEmpty ? IconButton(icon: Icon(Icons.camera_alt, color: AppTheme.blueGrey,), onPressed: _openCameraOptionSelection,) : Icon(Icons.face, color: AppTheme.darkBlue,)
                      : Text(""),
                ),
              ),
            ),
          ),
          Center(child: Text(_user != null ? _user.displayName : "", style: Theme.of(context).textTheme.headline,),),
          Center(child: Text(_user != null ? _user.email : "", style: Theme.of(context).textTheme.title,),),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Home", style: Theme.of(context).textTheme.title,),
                Text(_user != null ? _user.homeName : "", style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 0.9),)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Host", style: Theme.of(context).textTheme.title,),
                Text(_user != null ? _user.hostEmail : "", style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 0.9),)
              ],
            ),
          )
        ],
      ),
    );
  }

  void _openCameraOptionSelection() {
//    showModalBottomSheet(
//        context: context,
//        builder: (context) => BottomSheet(
//            onClosing: _onBottomSheetClosing,
//            builder: (context) => SizedBox(
//              height: 150,
//              child: Center(child: Text("hahaha", style: TextStyle(color: AppTheme.darkBlue),),),
//            )
//        )
//    );
  }

  @override
  void onUserLoaded(UserDetailEntity user) {
    if(user != null) {
      setState(() => _user = user);
    }
  }
}
