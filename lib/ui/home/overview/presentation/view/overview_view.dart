import 'package:flutter/material.dart';

import 'package:my_wallet/ui/home/overview/presentation/presenter/overview_presenter.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/data_observer.dart' as observer;

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/overview/presentation/view/overview_callback.dart';

class HomeOverview extends StatefulWidget {
  final TextStyle titleSTyle;

  HomeOverview(this.titleSTyle) : super();

  @override
  State<StatefulWidget> createState() {
    return _HomeOverviewState();
  }
}

class _HomeOverviewState extends CleanArchitectureView<HomeOverview, HomeOverviewPresenter> implements observer.DatabaseObservable, OverviewDataView {
  _HomeOverviewState() : super(HomeOverviewPresenter());

  final databaseWatch = [observer.tableAccount];

  final NumberFormat nf = NumberFormat("\$#,##0.00");

  var _total = 0.0;

  void onDatabaseUpdate(String table) {
    if (table == observer.tableAccount) presenter.loadTotal();
  }

  void init() {
    presenter.dataView = this;

    presenter.loadTotal();
  }

  void onLoadTotalSuccess(double value) {
    setState(() {
      _total = value;
    });
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(databaseWatch, this);
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(databaseWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Overview", style: widget.titleSTyle,),
          Text("${nf.format(_total)}", style: Theme.of(context).textTheme.headline.apply(fontSizeFactor: 1.8, color: _total <= 0 ? theme.pinkAccent : theme.tealAccent),)
        ],
      ),
    );
  }
}