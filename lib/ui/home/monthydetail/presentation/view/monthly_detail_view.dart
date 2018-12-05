import 'package:flutter/material.dart';

import 'package:my_wallet/app_theme.dart' as theme;

import 'package:my_wallet/ui/home/monthydetail/presentation/presenter/monthly_detail_presenter.dart';
import 'package:my_wallet/ui/home/monthydetail/data/monthly_detail_entity.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/data_observer.dart' as observer;

class HomeMonthlyDetail extends StatefulWidget {
  final TextStyle titleSTyle;

  HomeMonthlyDetail(this.titleSTyle) : super();
  @override
  State<StatefulWidget> createState() {
    return _HomeMonthlyDetailState();
  }
}

class _HomeMonthlyDetailState extends State<HomeMonthlyDetail> implements observer.DatabaseObservable {

  final databaseWatch = [observer.tableTransactions];

  final HomeMonthlyDetailPresenter _presenter = HomeMonthlyDetailPresenter();

  var _dataEntity = HomeMonthlyDetailEntity(0.0, 0.0, 0.0);

  DateFormat _df = DateFormat("MMMM yyyy");

  void onDatabaseUpdate(String table) {
    _loadAllData();
  }

  void _loadAllData() {
    _presenter.loadData().then((value) {
      setState(() {
        _dataEntity = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(databaseWatch, this);
    _loadAllData();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(databaseWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("${_df.format(DateTime.now())}", style: widget.titleSTyle.apply(color: Colors.white)),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Income", style: widget.titleSTyle,),
                    Text("\$${_dataEntity.income}", style: Theme.of(context).textTheme.headline,)
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Expenses", style: widget.titleSTyle,),
                    Text("\$${_dataEntity.expenses}", style: Theme.of(context).textTheme.headline,)
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Saving", style: widget.titleSTyle,),
                    Text("\$${_dataEntity.balance}", style: Theme.of(context).textTheme.headline.apply(color: (_dataEntity.balance > 0) ? Colors.greenAccent : theme.pinkAccent),)
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}