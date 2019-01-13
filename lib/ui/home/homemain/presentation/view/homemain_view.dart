import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/home/overview/presentation/view/overview_view.dart';
import 'package:my_wallet/ui/home/chart/chart_row_view.dart';
import 'package:my_wallet/ui/home/drawer/presentation/view/drawer_view.dart';

import 'package:my_wallet/ui/home/homemain/presentation/view/homemain_data_view.dart';
import 'package:my_wallet/ui/home/homemain/presentation/presenter/homemain_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:intl/intl.dart';

class MyWalletHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyWalletState();
  }
}

class _MyWalletState extends CleanArchitectureView<MyWalletHome, MyWalletHomePresenter> implements MyWalletHomeDataView, observer.DatabaseObservable {
  _MyWalletState() : super(MyWalletHomePresenter());
  final _titleStyle = TextStyle(color: AppTheme.blueGrey, fontSize: 14, fontWeight: FontWeight.bold);
  DateFormat _df = DateFormat("MMM, yyyy");

  final _overviewRatio = 0.15;
  final _chartRatio = 0.5;
  final _titleHeight = 22.0;

  final _tables = [observer.tableTransactions, observer.tableCategory];
  final _iconSize = 45.0;

  List<ExpenseEntity> _homeEntities = [];

  NumberFormat _nf = NumberFormat("\$#,##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(_tables, this);
    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(_tables, this);
  }

  void _loadDetails() {
    presenter.loadExpense();
  }

  void onExpensesDetailLoaded(List<ExpenseEntity> value) {
    setState(() {
      _homeEntities = value;
    });
  }

  void onDatabaseUpdate(String table) {
    _loadDetails();
  }


  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    return PlainScaffold(
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
    var screenHeight = MediaQuery.of(context).size.height;

    list.add(SliverAppBar(
      expandedHeight: screenHeight * (_overviewRatio + _chartRatio) + _titleHeight,
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
          collapseMode: CollapseMode.pin,
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

    list.add(SliverList(delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: index % 2 == 0 ? AppTheme.white : AppTheme.blueGrey.withOpacity(0.2),
            child: ListTile(
              leading: Container(
                width: _iconSize,
                height: _iconSize,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Icon(
                            Icons.monetization_on,
                            color: Color(AppTheme.hexToInt(_homeEntities[index].colorHex)),
                            size: _iconSize,),
                          heightFactor: _homeEntities[index].remainFactor,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      width: _iconSize,
                      height: _iconSize,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(AppTheme.hexToInt(_homeEntities[index].colorHex)), width: 1.0)
                      ),
                    )
                  ],
                ),
              ),
              onTap: () => Navigator.pushNamed(context, routes.TransactionList(_homeEntities[index].name, categoryId: _homeEntities[index].categoryId)),
              title: Text(_homeEntities[index].name, style: TextStyle(color: AppTheme.darkBlue),),
              trailing: Text(_nf.format(_homeEntities[index].expense), style: TextStyle(color: AppTheme.darkBlue),),
            ),
          );
        },
      childCount: _homeEntities.length,
    )));

    return CustomScrollView(
        slivers: list);
  }
}