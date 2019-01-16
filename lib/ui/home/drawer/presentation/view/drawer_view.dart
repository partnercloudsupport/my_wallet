import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/drawer/presentation/presenter/drawer_presenter.dart';
import 'package:my_wallet/ui/home/drawer/presentation/view/drawer_data_view.dart';

class LeftDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LeftDrawerState();
  }
}

class _LeftDrawerState extends CleanArchitectureView<LeftDrawer, LeftDrawerPresenter> implements LeftDrawerDataView {
  _LeftDrawerState() : super(LeftDrawerPresenter());

  final drawerListItems = [
    _DrawerTitle("Finance"),
    _DrawerItem("Categories", routes.ListCategories),
    _DrawerItem("Accounts", routes.ListAccounts),
    _DrawerItem("Budgets", routes.ListBudgets),
    _DrawerTitle("Profile"),
    _DrawerItem("Your profile", routes.UserProfile),
    _DrawerTitle("About"),
    _DrawerItem("About Us", routes.AboutUs)
  ];

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      width: MediaQuery.of(context).size.width * 0.85,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: ListView.builder(
              itemCount: drawerListItems.length,
              itemBuilder: (context, index) => drawerListItems[index].build(context),
              padding: EdgeInsets.all(10.0),
              shrinkWrap: true,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    child: Text("Sign Out", style: Theme.of(context).textTheme.title.apply(color: AppTheme.white),),
                    padding: EdgeInsets.all(10.0),
                  ),
                  Padding(
                    child: Icon(Icons.exit_to_app, color: AppTheme.white,),
                    padding: EdgeInsets.all(10.0),
                  ),
                ],
              ),
              onTap: () => presenter.signOut(),
            ),
          )
        ],
      ),
    );
  }

  @override
  void onSignOutSuccess(bool result) {
    Navigator.pushReplacementNamed(context, routes.Login);
  }

  @override
  void onSignOutFailed(Exception e) {

  }
}

abstract class _DrawerData {
  final String name;

  _DrawerData(this.name);

  Widget build(BuildContext context);
}

class _DrawerTitle extends _DrawerData{

  _DrawerTitle(String name) : super(name);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: AppTheme.blueGrey,
      child: Text(name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
    );
  }
}

class _DrawerItem extends _DrawerData {
  final String routeName;

  _DrawerItem(String name, this.routeName) : super(name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: Theme.of(context).textTheme.title.apply(color: Colors.white)),
      onTap: () => Navigator.popAndPushNamed(context, routeName),
    );
  }
}