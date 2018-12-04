import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:my_wallet/ui/home/chart/expense/data/expense_entity.dart';
import 'package:my_wallet/ui/home/chart/expense/presentation/presenter/chart_expense_presenter.dart';

class ExpenseChart extends StatefulWidget {

  ExpenseChart(GlobalKey key) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return ExpenseChartState();
  }
}

class ExpenseChartState extends State<ExpenseChart> {

  final ChartExpensePresenter _presenter = ChartExpensePresenter();

  List<ExpenseEntity> expenses = [];

  @override
  void initState() {
    super.initState();

    _loadExpense();
  }

  @override
  Widget build(BuildContext context) {
    return expenses == null || expenses.isEmpty
        ? Center(child: Text("No Expense found", style: Theme.of(context).textTheme.title,),)
        : PieChart([
          Series<ExpenseEntity, double>(
              data: expenses,
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
    _loadExpense();
  }

  void _loadExpense() {
    _presenter.loadExpense().then((data) {
      setState(() {
        expenses = data;
      });
    });
  }
}