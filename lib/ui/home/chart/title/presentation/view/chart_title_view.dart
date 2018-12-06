import 'package:flutter/material.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';
import 'package:my_wallet/ui/home/chart/title/presentation/presenter/chart_title_presenter.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/data_observer.dart' as observer;
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/chart/title/presentation/view/chart_title_data_view.dart';

class ChartTitleView extends StatefulWidget {
  final TabController _controller;

  ChartTitleView(this._controller);

  @override
  State<StatefulWidget> createState() {
    return _ChartTitleViewState();
  }
}

class _ChartTitleViewState extends CleanArchitectureView<ChartTitleView, ChartTitlePresenter> implements observer.DatabaseObservable, ChartTitleDataView {
  _ChartTitleViewState() : super(ChartTitlePresenter());

  final tableWatch = [
    observer.tableTransactions
  ];

  ChartTitleEntity entity;
  NumberFormat _nf = NumberFormat("#,##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tableWatch, this);

    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(tableWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.title;

    return TabBar(
              tabs: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Income",
                        style: textStyle.apply(color: theme.tealAccent),
                      ),
                      Text("${entity == null ? "\$0.00" : _nf.format(entity.incomeAmount)}",)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Expense",
                        style: textStyle.apply(color: theme.pinkAccent),
                      ),
                      Text("${entity == null ? "\$0.00" : _nf.format(entity.expensesAmount)}",)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Saving",
                      style: textStyle.apply(color: theme.brightGreen),
                      ),
                      Text("${entity == null ? "\$0.00" : _nf.format(entity.savingAmount)}")
                    ],
                  ),
                )
              ],
              controller: widget._controller,
              indicatorWeight: 4.0,
              indicatorColor: Colors.white.withOpacity(0.8),
            );
  }

  void _loadDetails() {
    presenter.loadTitleDetail();
  }

  void onDetailLoaded(ChartTitleEntity value) {
    setState(() {
      entity = value;
    });
  }

  void onDatabaseUpdate(String table) {
    _loadDetails();
  }
}