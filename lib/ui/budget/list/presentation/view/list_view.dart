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

  var _tables = [observer.tableBudget, observer.tableCategory];

  var _budgetList = <BudgetEntity>[];
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
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Your budget settings",
      ),
      body: Column(
        children: <Widget>[
          InkWell(
            child: Stack(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      df.format(_month),
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_right),
                  ),
                )
              ],
            ),
            onTap: () => Navigator.push(
                context,
                SlidePageRoute(
                    builder: (_) => Scaffold(
                          appBar: MyWalletAppBar(
                            title: "Select a month",
                          ),
                          body: ListView.builder(
                            itemBuilder: (_, index) {
                              DateTime newTime = monthsAfter(DateTime.now(), index);
                              return ListTile(
                                title: Center(
                                  child: Text(
                                    df.format(newTime),
                                    style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);

                                  setState(() => _month = newTime);

                                  loadData();
                                },
                              );
                            },
                            itemCount: maxMonthSupport,
                          ),
                        ))),
          ),
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
}
