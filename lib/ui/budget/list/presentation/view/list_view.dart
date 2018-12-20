import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/list/presentation/presenter/list_presenter.dart';
import 'package:my_wallet/ui/budget/list/presentation/view/list_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:my_wallet/ui/budget/budget_config.dart';

class ListBudgets extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListBudgetsState();
  }
}

class _ListBudgetsState extends CleanArchitectureView<ListBudgets, ListBudgetsPresenter> implements ListBudgetsDataView, observer.DatabaseObservable {
  _ListBudgetsState() : super(ListBudgetsPresenter());

  var _tables = [observer.tableBudget, observer.tableCategory, observer.tableTransactions];

  var _budgetList = <BudgetEntity>[];
  var _nf = NumberFormat("\$##0.00");

  var _month = DateTime.now();

  final crossAxisCount = 3;

  var _summaryKey = GlobalKey<_MonthSummaryState>();

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    loadData();

    if(table == observer.tableBudget || table == observer.tableTransactions) {
      loadSummary();
    }
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(_tables, this);

    loadData();
    loadSummary();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(_tables, this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width / crossAxisCount - 20;
    var padding = size / 4;
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Your budget settings",
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Text(df.format(_month), style: Theme.of(context).textTheme.title,),
          ),
          _MonthSummary(_summaryKey, _month, (month) {
            _month = month;
            loadData();
          }),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
            itemCount: _budgetList.length + 1,
            itemBuilder: (context, index) {
              if (index == _budgetList.length) return _btnAddCategory(padding);

              return _budgetItem(index, padding);
            },
          )
        ],
      ),
    );
  }

  Widget _btnAddCategory(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: CircleAvatar(
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, routes.CreateCategory).then((value) {
              if (value != null) Navigator.pushNamed(context, routes.EditBudget(categoryId: value, month: _month));
            });
          },
          icon: Icon(
            Icons.add,
            color: AppTheme.darkBlue,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _budgetItem(int index, padding) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routes.EditBudget(categoryId: _budgetList[index].categoryId, month: _month)),
      child: Center(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: _budgetList == null ? 0.0 : _budgetList[index].total == 0 ? 0.0 : _budgetList[index].spent / _budgetList[index].total,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.pinkAccent, width: 3.0)),
                  ),
                  Center(
                    child: Text(
                      "${_nf.format(_budgetList[index].total)}",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  )
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  _budgetList[index].categoryName,
                  style: Theme.of(context).textTheme.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    );
  }

  @override
  void onBudgetLoaded(List<BudgetEntity> list) {
    setState(() => _budgetList = list);
  }

  void loadData() {
    presenter.loadThisMonthBudgetList(_month);
  }

  void loadSummary() {
    presenter.loadSummary();
  }

  @override
  void onSummaryLoaded(List<BudgetSummary> summary) {
    if(_summaryKey.currentState != null) {
      _summaryKey.currentState.updateSummary(summary);
    }
  }
}

class _MonthSummary extends StatefulWidget {
  final DateTime month;
  final ValueChanged<DateTime> onMonthSelected;

  _MonthSummary(key, this.month, this.onMonthSelected) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MonthSummaryState();
  }
}

class _MonthSummaryState extends State<_MonthSummary> {
  DateTime _month;
  List<BudgetSummary> summary = [];
  var _nf = NumberFormat("\$##0.00");
  final _columnWidth = 50.0;
  final _columnHeight = 110.0;

  void updateSummary(List<BudgetSummary> summary) {
    setState(() => this.summary = summary);
  }

  @override
  void initState() {
    super.initState();

    _month = widget.month;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _columnHeight,
//      color: AppTheme.white,
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
      child: ListView.builder(
        itemBuilder: (_, index) => Padding(
          child: InkWell(
            child: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: _columnWidth,
                  color: Color(0xff7e7db7),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: _columnWidth,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: summary == null || index >= summary.length ? 0.0 : summary[index].total == 0 ? 0.0 : summary[index].spent / summary[index].total,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color.lerp(AppTheme.tealAccent, AppTheme.pinkAccent, summary == null || index >= summary.length || summary[index].total == 0 ? 0.0 : summary[index].spent / summary[index].total )
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: _columnWidth,
                  child: Text(
                      summary == null || index >= summary.length ? "" : "${df.format(summary[index].month)}",
                    style: Theme.of(context).textTheme.subhead.apply(color: AppTheme.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            onTap: () => widget.onMonthSelected(summary[index].month),
          ),
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
        ),
        itemCount: summary.length < maxMonthSupport ? maxMonthSupport : summary.length,
      scrollDirection: Axis.horizontal,),
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    return InkWell(
//      child: Stack(
//        children: <Widget>[
//          Center(
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Text(
//                df.format(_month),
//                style: Theme.of(context).textTheme.title,
//              ),
//            ),
//          ),
//          Align(
//            alignment: Alignment.centerRight,
//            child: Padding(
//              padding: EdgeInsets.all(8.0),
//              child: Icon(Icons.arrow_right),
//            ),
//          )
//        ],
//      ),
//      onTap: () => Navigator.push(
//          context,
//          SlidePageRoute(
//              builder: (_) => Scaffold(
//                appBar: MyWalletAppBar(
//                  title: "Select a month",
//                ),
//                body: ListView.builder(
//                  itemBuilder: (_, index) {
//                    DateTime newTime = monthsAfter(DateTime.now(), index);
//                    return ListTile(
//                      title: Center(
//                        child: Text(
//                          df.format(newTime),
//                          style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
//                        ),
//                      ),
//                      onTap: () {
//                        Navigator.pop(context);
//
//                        setState(() => _month = newTime);
//
//                        widget.onMonthSelected(_month);
//                      },
//                    );
//                  },
//                  itemCount: maxMonthSupport,
//                ),
//              ))),
//    );
//  }
}