import 'package:flutter/material.dart';

import 'package:my_wallet/ui/home/chart/transactions/presentation/view/chart_transaction.dart';
import 'package:my_wallet/ui/home/chart/title/presentation/view/chart_title_view.dart';
import 'package:my_wallet/ui/home/chart/saving/presentation/view/chart_saving_view.dart';

class ChartRow extends StatefulWidget {
  final double height;
  ChartRow(this.height) : super();

  @override
  State<StatefulWidget> createState() {
    return _ChartRowState();
  }
}

class _ChartRowState extends State<ChartRow> with TickerProviderStateMixin {
  TabController _tabController;
  final _tabViews = [
    IncomeChart(),
    ExpenseChart(),
    SavingChartView(),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabViews.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          ChartTitleView(_tabController,height: widget.height * 0.25),
          Container(
            height: widget.height * 0.75,
            child: TabBarView(controller: _tabController, children: _tabViews),
          )
        ],
      ),
    );
  }
}
