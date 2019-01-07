import 'package:my_wallet/app_material.dart';

import 'package:intl/intl.dart';

import 'package:my_wallet/ui/home/overview/presentation/view/overview_view.dart';
import 'package:my_wallet/ui/home/chart/chart_row_view.dart';
import 'package:my_wallet/ui/home/expenseslist/presentation/view/expense_list_view.dart';
import 'package:my_wallet/ui/home/drawer/presentation/view/drawer_view.dart';

class MyWalletHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyWalletState();
  }
}

class _MyWalletState extends State<MyWalletHome> {
  final _titleStyle = TextStyle(color: AppTheme.blueGrey, fontSize: 14, fontWeight: FontWeight.bold);
  DateFormat _df = DateFormat("MMM, yyyy");

  final _overviewRatio = 0.15;
  final _chartRatio = 0.5;
  final _titleHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    return GradientScaffold(
      body: _generateMainBody(),
      drawer: LeftDrawer(),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(platform == TargetPlatform.iOS ? 10.0 : 0.0),
        child: RoundedButton(
          onPressed: () => Navigator.pushNamed(context, routes.AddTransaction),
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Text(
              "Add Transaction",
            ),
          ),
          color: AppTheme.pinkAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _generateMainBody() {
    List<Widget> list = [];

    list.add(SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * (_overviewRatio + _chartRatio) + _titleHeight,
      pinned: true,
      flexibleSpace: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: SizedBox(
            height: _titleHeight,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                _df.format(DateTime.now()),
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
          collapseMode: CollapseMode.parallax,
          background: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              HomeOverview(_titleStyle, MediaQuery.of(context).size.height * _overviewRatio),
              ChartRow(MediaQuery.of(context).size.height * _chartRatio),
            ],
          ),
        ),
      ),
    ));

    list.add(
      SliverFillRemaining(
        child: ExpensesListView(),
      ),
    );

    return CustomScrollView(
        slivers: list);
  }
}
