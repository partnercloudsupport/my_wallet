import 'package:my_wallet/app_material.dart';

import 'package:intl/intl.dart';

import 'package:my_wallet/ui/home/overview/presentation/view/overview_view.dart';
import 'package:my_wallet/ui/home/chart/chart_row_view.dart';
import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';
import 'package:my_wallet/ui/home/expenseslist/presentation/view/expense_list_view.dart';

class MyWalletHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyWalletState();
  }
}

class _MyWalletState extends State<MyWalletHome> {

  TextStyle titleStyle = TextStyle(color: AppTheme.blueGrey, fontSize: 14, fontWeight: FontWeight.bold);
  List<ExpenseEntity> homeEntities = [];

  DateFormat _df = DateFormat("MMM, yyyy");

  final overviewRatio = 0.15;
  final chartRatio = 0.5;
  final titleHeight = 22.0;


  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    return GradientScaffold(
      body: _generateMainBody(),
      drawer: _LeftDrawer(),
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
      expandedHeight: MediaQuery.of(context).size.height * (overviewRatio + chartRatio) + titleHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: SizedBox(
          height: titleHeight,
          child: Center(
            child: Text(_df.format(DateTime.now()), style: Theme.of(context).textTheme.title,),
          ),
        ),
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.bgGradient
          ),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              HomeOverview(titleStyle, MediaQuery.of(context).size.height * overviewRatio),
              ChartRow(MediaQuery.of(context).size.height * chartRatio),
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
        slivers: list
    );
  }
}

class _LeftDrawer extends StatelessWidget {
  final drawerListItems = {
    "Categories": routes.ListCategories,
    "Accounts": routes.ListAccounts};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      width: MediaQuery.of(context).size.width * 0.85,
      alignment: Alignment.center,
      child: ListView(
        padding: EdgeInsets.all(10.0),
        shrinkWrap: true,
        children: drawerListItems.keys
            .map((f) => ListTile(
          title: Text(
            f,
            style: Theme.of(context).textTheme.title.apply(color: Colors.white),
          ),
          onTap: () => Navigator.popAndPushNamed(context, drawerListItems[f]),
        ))
            .toList(),
      ),
    );
  }
}