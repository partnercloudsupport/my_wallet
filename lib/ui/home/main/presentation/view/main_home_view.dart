import 'package:flutter/material.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:intl/intl.dart';

import 'package:my_wallet/ui/home/overview/presentation/view/overview_view.dart';
import 'package:my_wallet/ui/home/chart/chart_row_view.dart';
import 'package:my_wallet/routes.dart' as routes;
import 'package:my_wallet/ui/home/main/data/main_home_entity.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';

import 'package:my_wallet/ui/home/main/presentation/presenter/main_home_presenter.dart';

class MyWalletHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyWalletState();
  }
}

class _MyWalletState extends State<MyWalletHome> {

  final HomePresenter _presenter = HomePresenter();

  TextStyle titleSTyle = TextStyle(color: theme.blueGrey, fontSize: 14, fontWeight: FontWeight.bold);
  List<HomeEntity> homeEntities = [];

  DateFormat _df = DateFormat("MMM, yyyy");

  @override
  void initState() {
    super.initState();

    _presenter.loadHome().then((value) {
      setState(() {
        print("Home loaded ${value.length}");
        homeEntities = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    return Scaffold(
      body: _generateMainBody(),
      drawer: _LeftDrawer(),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(platform == TargetPlatform.iOS ? 10.0 : 0.0),
        child: RaisedButton(
          onPressed: () => Navigator.pushNamed(context, routes.AddTransaction),
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Text(
              "Add Transaction",
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          color: theme.pinkAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _generateMainBody() {
    List<Widget> list = [];

    list.add(SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.55,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_df.format(DateTime.now()), style: Theme.of(context).textTheme.title,),
        background: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomeOverview(titleSTyle),
            ChartRow(),
          ],
        ),
      ),
    ));

    list.add(
        SliverFillRemaining(
          child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: homeEntities.map((f) => ListTile(
                  title: Text(f.name, style: TextStyle(color: theme.darkBlue),),
                  leading: Icon(Icons.map, color: theme.darkBlue,),
                  trailing: Text("\$${f.amount}", style: TextStyle(color: theme.tealAccent),),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionList(f.name, categoryId: f.categoryId,))),
                )).toList(),
              ),
          ),
    );
    return CustomScrollView(
      slivers: list
    );
  }
}

class _LeftDrawer extends StatelessWidget {
  final drawerListItems = {
    "Categories": routes.ListCategories,
    "Accounts": routes.ListAccounts};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      width: MediaQuery.of(context).size.width * 0.85,
      alignment: Alignment.center,
      child: ListView(
        padding: EdgeInsets.all(10.0),
        shrinkWrap: true,
        children: drawerListItems.keys
            .map((f) => ListTile(
          title: Text(
            f,
            style: Theme.of(context).textTheme.title.apply(color: Colors.white),
          ),
          onTap: () => Navigator.popAndPushNamed(context, drawerListItems[f]),
        ))
            .toList(),
      ),
    );
  }
}