import 'package:flutter/material.dart';

import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/ui/home/chart/saving/presentation/presenter/chart_saving_presenter.dart';
import 'package:intl/intl.dart';

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/chart/saving/presentation/view/chart_saving_data_view.dart';
import 'package:my_wallet/data_observer.dart' as observer;

class SavingChartView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SavingChartViewState();
  }
}

class _SavingChartViewState extends CleanArchitectureView<SavingChartView, SavingChartPresenter> implements ChartSavingDataView, observer.DatabaseObservable {

  _SavingChartViewState() : super(SavingChartPresenter());

  final tables = [
    observer.tableTransactions
  ];

  final NumberFormat _nf = NumberFormat("\$#,##0.00");

  SavingEntity entity;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    loadChartData();
  }

  @override
  void dispose() {

    observer.unregisterDatabaseObservable(tables, this);
    super.dispose();
  }

  void onDatabaseUpdate(String table) {
    loadChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: entity == null ? 0.0 : entity.fraction,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent),
                ),
              ),
            ),
          ),
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.pinkAccent, width: 3.0)),
              child: Text(entity == null ? "\$0.00" : _nf.format(entity.monthlySaving), style: Theme.of(context).textTheme.display2,)
          ),
        ],
      ),
    );
  }

  void loadChartData() {
    presenter.loadSaving();
  }

  void onDataAvailable(SavingEntity value) {
    setState(() {
      entity = value;
    });
  }
}