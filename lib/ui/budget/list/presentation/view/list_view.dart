import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/list/presentation/presenter/list_presenter.dart';
import 'package:my_wallet/ui/budget/list/presentation/view/list_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:intl/intl.dart';

class ListBudgets extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListBudgetsState();
  }
}

class _ListBudgetsState extends CleanArchitectureView<ListBudgets, ListBudgetsPresenter> implements ListBudgetsDataView, observer.DatabaseObservable {

  _ListBudgetsState() : super(ListBudgetsPresenter());

  var tables = [observer.tableBudget, observer.tableCategory];

  var budgetList = <BudgetEntity>[];
  var _nf = NumberFormat("\$##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    presenter.loadThisMonthBudgetList();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    presenter.loadThisMonthBudgetList();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width / 4 - 20;
    var padding = size /4;
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Your budget settings",
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: budgetList.length + 1,
        itemBuilder: (context, index) {
          if(index == budgetList.length) return _btnAddCategory(padding);

          return _budgetItem(index, padding);
        },
      ),
    );
  }

  Widget _btnAddCategory(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: CircleAvatar(
        child: IconButton(
          onPressed: () => Navigator.pushNamed(context, routes.AddBudget),
          icon: Icon(Icons.add, color: AppTheme.darkBlue, size: 30,),),
      ),
    );
  }

  Widget _budgetItem(int index, padding) {
    return Center(
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
                      heightFactor: budgetList == null ? 0.0 : budgetList[index].total == 0 ? 0.0 : budgetList[index].spent / budgetList[index].total,
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
                Center(child: Text("${_nf.format(budgetList[index].total)}", style: Theme.of(context).textTheme.subhead,),)
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(budgetList[index].categoryName, style: Theme.of(context).textTheme.title,)
          )
        ],
      ),);
  }

  @override
  void onBudgetLoaded(List<BudgetEntity> list) {
    setState(() => budgetList = list);
  }
}