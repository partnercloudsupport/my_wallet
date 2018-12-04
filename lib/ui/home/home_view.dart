import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';

import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ui/home/overview/presentation/view/overview_view.dart';
import 'package:my_wallet/ui/home/monthydetail/presentation/view/monthly_detail_view.dart';
import 'package:my_wallet/ui/home/chart/presentation/view/chart_row_view.dart';
import 'package:my_wallet/ui/home/expenses/presentation/view/expenses_view.dart';
import 'package:my_wallet/routes.dart' as routes;
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';

class MyWalletHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyWalletState();
  }
}

class _MyWalletState extends State<MyWalletHome> {
  TextStyle titleSTyle = TextStyle(
    color: theme.blueGrey,
    fontSize: 14,
    fontWeight: FontWeight.bold
  );

  GlobalKey<ExpensesState> expensesKey = GlobalKey();
  GlobalKey<HomeMonthlyDetailState> monthlyDetailKey = GlobalKey();
  GlobalKey<HomeOverviewState> overviewKey = GlobalKey();
  GlobalKey<ChartRowState> chartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Wallet",
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.calendar_today),
          )
        ],
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            HomeOverview(overviewKey, titleSTyle),
            HomeMonthlyDetail(monthlyDetailKey, titleSTyle),
            ChartRow(chartKey),
            Expenses(expensesKey)
          ],
        ),
        decoration: BoxDecoration(
          color: theme.darkBlue
        ),
      ),
      drawer: _LeftDrawer(),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(platform == TargetPlatform.iOS ? 10.0 : 0.0),
      child: RaisedButton(
        onPressed: () =>  Navigator.pushNamed(context, routes.AddTransaction)
            .then((updated) {
              if (updated == true) {
                // refresh all views
                overviewKey.currentState.refresh();
                monthlyDetailKey.currentState.refresh();
                expensesKey.currentState.refresh();
                chartKey.currentState.refresh();
              }
        }),
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Text("Add Transaction",),
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        color: theme.pinkAccent,
      ),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _LeftDrawer extends StatelessWidget {
  final drawerListItems = {
    "Categories": routes.ListCategories,
    "Accounts": routes.ListAccounts
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark
      ),
      width: MediaQuery.of(context).size.width * 0.85,
      alignment: Alignment.center,
      child: ListView(
        padding: EdgeInsets.all(10.0),
        shrinkWrap: true,
        children: drawerListItems.keys.map((f) => ListTile(
          title: Text(f),
          onTap: () => Navigator.popAndPushNamed(context, drawerListItems[f]),
        )).toList(),
      ),
    );
  }
}