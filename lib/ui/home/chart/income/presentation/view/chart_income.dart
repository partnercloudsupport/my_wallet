import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:my_wallet/ui/home/chart/income/data/income_entity.dart';
import 'package:my_wallet/ui/home/chart/income/presentation/presenter/chart_income_presenter.dart';

class IncomeChart extends StatefulWidget {

  IncomeChart(GlobalKey key) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return IncomeChartState();
  }
}

class IncomeChartState extends State<IncomeChart> {

  final ChartIncomePresenter _presenter = ChartIncomePresenter();

  List<IncomeEntity> incomes = [];

  @override
  void initState() {
    super.initState();

    _loadIncome();
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

  void refresh() {
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