import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:my_wallet/ui/home/chart/income/data/income_entity.dart';
import 'package:my_wallet/ui/home/chart/income/presentation/presenter/chart_income_presenter.dart';
import 'package:my_wallet/data_observer.dart' as observer;

class IncomeChart extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _IncomeChartState();
  }
}

class _IncomeChartState extends State<IncomeChart> implements observer.DatabaseObservable {

  final ChartIncomePresenter _presenter = ChartIncomePresenter();
  final databaseWatch = [
    observer.tableTransactions,
    observer.tableCategory
  ];

  List<IncomeEntity> incomes = [];

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(databaseWatch, this);
    _loadIncome();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(databaseWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    return incomes == null || incomes.isEmpty
        ? Center(child: Text("No Income found", style: Theme.of(context).textTheme.title,),)
        : PieChart(
          [
            Series<IncomeEntity, double>(
                data: incomes,
                measureFn: (data, index) => data.amount,
                domainFn: (data, index) => data.amount,
                colorFn: (data, index) => Color.fromHex(code: data.color),
                labelAccessorFn: (data, index) => "${data.category}"
            ),
          ],
          animate: false,
          defaultRenderer: ArcRendererConfig(
              arcRendererDecorators: [ ArcLabelDecorator() ]
          ),
    );
  }

  void onDatabaseUpdate(String table) {
    _loadIncome();
  }

  void _loadIncome() {
    _presenter.loadIncome().then((data) {
      setState(() {
        incomes = data;
      });
    });
  }
}