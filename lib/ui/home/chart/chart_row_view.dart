import 'package:flutter/material.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ui/home/chart/income/presentation/view/chart_income.dart';
import 'package:my_wallet/ui/home/chart/expense/presentation/view/chart_expense.dart';

/// show a bar chart of 7 days expenses and income
class ChartRow extends StatefulWidget {
  ChartRow(GlobalKey key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartRowState();
  }
}

class ChartRowState extends State<ChartRow> with TickerProviderStateMixin {
  TabController _tabController;

  GlobalKey<IncomeChartState> _incomeState = GlobalKey();
  GlobalKey<ExpenseChartState> _expenseState = GlobalKey();

  void refresh() {
    if(_incomeState.currentState != null) _incomeState.currentState.refresh();
    if(_expenseState.currentState != null) _expenseState.currentState.refresh();
  }


  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.title;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Income",
                    style: textStyle.apply(color: theme.tealAccent),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Expenses",
                    style: textStyle.apply(color: theme.pinkAccent),
                  ),
                )
              ],
              controller: _tabController,
              indicatorWeight: 2.0,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: TabBarView(controller: _tabController, children: [IncomeChart(_incomeState), ExpenseChart(_expenseState)]),
            )
          ],
        ),
      ),
    );
  }
}
