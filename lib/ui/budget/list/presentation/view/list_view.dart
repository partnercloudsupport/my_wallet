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

  final _controller = FixedExtentScrollController();

  BudgetListEntity _budgetList = BudgetListEntity.empty();
  var _nf = NumberFormat("\$##0.00");

  var _month = DateTime.now();

  final crossAxisCount = 3;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    loadData();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(_tables, this);

    loadData();
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
    final _style = Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue);

    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Your budget settings",
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_left,),
                  onPressed: () {
                    _month = monthsAfter(_month, -1);
                    loadData();
                  },
                  iconSize: 20.0,
                ),
              ),
              Text(df.format(_month), style: Theme.of(context).textTheme.title,),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                    icon: Icon(Icons.arrow_right,),
                    onPressed: () {
                      _month = monthsAfter(_month, 1);
                      loadData();
                    },
                    iconSize: 20.0,),
              )
            ],
          ),
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
}