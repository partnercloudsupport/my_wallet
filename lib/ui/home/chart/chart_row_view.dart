import 'package:flutter/material.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ui/home/chart/income/presentation/view/chart_income.dart';
import 'package:my_wallet/ui/home/chart/expense/presentation/view/chart_expense.dart';

import 'package:my_wallet/ui/home/chart/title/presentation/view/chart_title_view.dart';
import 'package:my_wallet/ui/home/chart/saving/presentation/view/chart_saving_view.dart';

class ChartRow extends StatefulWidget {
  ChartRow() : super();

  @override
  State<StatefulWidget> createState() {
    return _ChartRowState();
  }
}

class _ChartRowState extends State<ChartRow> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          ChartTitleView(_tabController,),
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: TabBarView(controller: _tabController, children: [IncomeChart(), ExpenseChart(), SavingChartView()]),
          )
        ],
      ),
    );
  }
}
