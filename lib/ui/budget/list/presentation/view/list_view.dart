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

typedef OnMonthSelected = Function(DateTime month, double budget);

class _ListBudgetsState extends CleanArchitectureView<ListBudgets, ListBudgetsPresenter> implements ListBudgetsDataView, observer.DatabaseObservable {
  _ListBudgetsState() : super(ListBudgetsPresenter());

  var _tables = [observer.tableBudget, observer.tableCategory, observer.tableTransactions];

  BudgetListEntity _budgetList = BudgetListEntity.empty();
  var _nf = NumberFormat("\$##0.00");

  var _month = DateTime.now();
  var _amount = 0.0;

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
          _MonthSummary(_summaryKey, _month, (month, total) {
            _month = month;
            _amount = total;
            loadData();
          }),
//          Padding(
//            padding: EdgeInsets.all(8.0),
//            child: Text("Total ${_nf.format(_amount)}", style: Theme.of(context).textTheme.title,),
//          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildTitle(CategoryType.expense, _budgetList.totalExpense, _budgetList.expenseBudget),
                _buildGrid(_budgetList.expense, padding),
                _buildTitle(CategoryType.income, _budgetList.totalIncome, _budgetList.incomeBudget),
                _buildGrid(_budgetList.income, padding)
              ],
            )
          )
        ],
      ),
    );
  }

  Widget _buildTitle(CategoryType type, double total, double budget) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            type.name,
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _nf.format(total),
                  style: Theme.of(context).textTheme.title.apply(color: type == CategoryType.expense ? AppTheme.red : AppTheme.tealAccent)
                ),
                TextSpan(
                  text: " / ${_nf.format(budget)}",
                  style: Theme.of(context).textTheme.title
                ),
              ]
            ),
          )
        ],
      ),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: AppTheme.transparent,
        border: Border.all(color: AppTheme.white)
      ),
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: 8.0,),
    );
  }

  Widget _buildGrid(List<BudgetEntity> entities, double padding) {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
      itemCount: (entities == null ? 0 : entities.length) + 1,
      itemBuilder: (context, index) {
        if (index == (entities == null ? 0 : entities.length)) return _btnAddBudget(padding);

        return _budgetItem(entities[index], padding);
      },
    );
  }

  Widget _btnAddBudget(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: CircleAvatar(
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, routes.SelectCategory)
                .then((value) {
              if (value != null) Navigator.pushNamed(context, routes.EditBudget(categoryId: value, month: _month));
            });
//            Navigator.pushNamed(context, routes.CreateCategory).then((value) {
//              if (value != null) Navigator.pushNamed(context, routes.EditBudget(categoryId: value, month: _month));
//            });
          },
          icon: Icon(
            Icons.add,
            color: AppTheme.darkBlue,
            size: 30.0,
          ),
        ),
      ),
    );
  }

  Widget _budgetItem(BudgetEntity entity, double padding) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routes.EditBudget(categoryId: entity.categoryId, month: _month)),
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
                        heightFactor: _budgetList == null ? 0.0 : entity.total == 0 ? 0.0 : entity.transaction / entity.total,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Color(AppTheme.hexToInt(entity.colorHex))),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.pinkAccent, width: 3.0)),
                  ),
                  Center(
                    child: Text(
                      "${_nf.format(entity.total)}",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  )
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  entity.categoryName,
                  style: Theme.of(context).textTheme.title.apply(color: Color(AppTheme.hexToInt(entity.colorHex))),
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
  void onBudgetLoaded(BudgetListEntity list) {
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
      _summaryKey.currentState.updateSummary(summary, _month);
    }
  }
}

class _MonthSummary extends StatefulWidget {
  final DateTime month;
  final OnMonthSelected onMonthSelected;

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
  var _columnWidth = 50.0;
  var _columnHeight = 110.0;

  final _simpleDf = DateFormat("MMM");

  void updateSummary(List<BudgetSummary> summary, DateTime month) {
    setState(() => this.summary = summary);

    this._month = month;

    if(summary != null && summary.isNotEmpty) {
      widget.onMonthSelected(summary[0].month, summary[0].total);
    }
  }

  @override
  void initState() {
    super.initState();

    _month = widget.month;
  }

  @override
  Widget build(BuildContext context) {
    _columnWidth = MediaQuery.of(context).size.width / 7;
    _columnHeight = _columnWidth * 2;

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
                  decoration: BoxDecoration(
                    border: Border.all(color: summary != null && summary.isNotEmpty && index < summary.length && _isSelected(summary[index].month, _month)  ? AppTheme.white : AppTheme.transparent, width: 1.0),
                    color: AppTheme.lightBlue.withOpacity(0.5),
                  ),
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
                  alignment: Alignment.topCenter,
                  width: _columnWidth,
                  child: Text(
                      summary == null || index >= summary.length ? "${showYear(monthsAfter(DateTime.now(), index))}" : "${showYear(summary[index].month)}",
                    style: Theme.of(context).textTheme.caption.apply(color: AppTheme.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: _columnWidth,
                  child: Text(
                    summary == null || index >= summary.length ? "${_simpleDf.format(monthsAfter(DateTime.now(), index))}" : "${_simpleDf.format(summary[index].month)}",
                    style: Theme.of(context).textTheme.caption.apply(color: AppTheme.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            onTap: () {
              widget.onMonthSelected(summary[index].month, summary[index].total);
              _month = summary[index].month;

              setState(() {});
            },
          ),
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
        ),
        itemCount: summary.length < maxMonthSupport ? maxMonthSupport : summary.length,
      scrollDirection: Axis.horizontal,),
    );
  }

  bool _isSelected(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String showYear(DateTime time) {
    return time.month == DateTime.january ? "${time.year}" : "";
  }
}