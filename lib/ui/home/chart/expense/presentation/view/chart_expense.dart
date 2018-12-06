import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:my_wallet/ui/home/chart/expense/data/expense_entity.dart';
import 'package:my_wallet/ui/home/chart/expense/presentation/presenter/chart_expense_presenter.dart';
import 'package:my_wallet/data_observer.dart' as observer;

class ExpenseChart extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ExpenseChartState();
  }
}

class _ExpenseChartState extends State<ExpenseChart> implements observer.DatabaseObservable {

  final databaseWatch = [
    observer.tableTransactions,
    observer.tableCategory
  ];

  final ChartExpensePresenter _presenter = ChartExpensePresenter();

  List<ExpenseEntity> expenses = [];

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(databaseWatch, this);
    _loadExpense();
  }

  @override
  void dispose() {
    super.dispose();

    print("dispose chart expenses");
    observer.unregisterDatabaseObservable(databaseWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    return expenses == null || expenses.isEmpty
        ? Center(child: Text("No Expense found", style: Theme.of(context).textTheme.title,),)
        : PieChart([
          Series<ExpenseEntity, double>(
              id: "_expenses",
              data: expenses,
              measureFn: (data, index) => data.amount,
              domainFn: (data, index) => data.amount,
              colorFn: (data, index) => Color.fromHex(code: data.color),
              labelAccessorFn: (data, index) => "${data.category} : ${data.amount}"
          ),
    ],
      animate: false,
      defaultRenderer: ArcRendererConfig(
          arcRendererDecorators: [ ArcLabelDecorator() ]
      ),
    );
  }

  void onDatabaseUpdate(String table) {
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