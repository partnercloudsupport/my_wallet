import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:my_wallet/ui/home/chart/presentation/presenter/chart_row_presenter.dart';
import 'package:my_wallet/ui/home/chart/data/chart_entity.dart';
import 'package:my_wallet/app_theme.dart' as theme;

/// show a bar chart of 7 days expenses and income
class ChartRow extends StatefulWidget {

  ChartRow(GlobalKey key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartRowState();
  }
}

class ChartRowState extends State<ChartRow> {
  final ChartPresenter _presenter = ChartPresenter();

  ChartEntity _chartData;

  void refresh() {
    _loadChartData();
  }

  void _loadChartData() {
    _presenter.loadChartData()
        .then((data) {
      if (data != null) {
        setState(() {
          _chartData = data;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _loadChartData();
  }

  @override
  Widget build(BuildContext context) {
    var lineWidth = MediaQuery.of(context).size.width * 0.1;
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 2,
                    width: lineWidth,
                    color: theme.tealAccent,
                  ),
                  Padding(
                    child: Text("Income", style: TextStyle(color: theme.tealAccent, fontSize: 18.0),),
                    padding: EdgeInsets.all(10.0),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 2,
                    width: lineWidth,
                    color: theme.pinkAccent,
                  ),
                  Padding(
                    child: Text("Expenses", style: TextStyle(color: theme.pinkAccent, fontSize: 18.0),),
                    padding: EdgeInsets.all(10.0),
                  )
                ],
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: _isDataAvailable(_chartData)
                ? Text("No Data Available")
                : TimeSeriesChart(
              <Series<TransactionEntity, DateTime>>[
                Series<TransactionEntity, DateTime>(
                    id: "income",
                    data: _chartData.income == null ? [] : _chartData.income,
                    domainFn: (data, index) => data.month,
                    measureFn: (data, _) => data.amount,
                    colorFn: (data, index) => Color.fromHex(code: "#10EDC5")
                ),
                Series<TransactionEntity, DateTime> (
                    id: "expense",
                    data: _chartData.expense == null ? [] : _chartData.expense,
                    domainFn: (data, index) => data.month,
                    measureFn: (data, _) => data.amount,
                    colorFn: (data, index) => Color.fromHex(code: "#ED1946")
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool _isDataAvailable(ChartEntity chartData) {
    return chartData == null || (
        (_chartData.income == null || chartData.income.isEmpty)
        && (_chartData.expense == null || chartData.expense.isEmpty)
    );
  }
}