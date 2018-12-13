import 'package:intl/intl.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';

import 'package:my_wallet/ui/home/expenseslist/presentation/presenter/expense_list_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/expenseslist/presentation/view/expese_list_dataview.dart';

class ExpensesListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpensesListViewState();
  }
}

class _ExpensesListViewState extends CleanArchitectureView<ExpensesListView, ExpensePresenter> implements observer.DatabaseObservable, ExpenseDataView {

  _ExpensesListViewState() : super(ExpensePresenter());

  final tables = [
    observer.tableTransactions,
    observer.tableCategory
  ];

  TextStyle titleStyle = TextStyle(color: AppTheme.blueGrey, fontSize: 14, fontWeight: FontWeight.bold);
  List<ExpenseEntity> homeEntities = [];

  NumberFormat _nf = NumberFormat("\$#,##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);
    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(tables, this);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: AppTheme.white,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: homeEntities.map((f) => ListTile(
          title: Text(f.name, style: TextStyle(color: AppTheme.darkBlue),),
          leading: Icon(Icons.map, color: AppTheme.darkBlue,),
          trailing: Text(_nf.format(f.amount), style: TextStyle(color: AppTheme.tealAccent),),
          onTap: () => Navigator.pushNamed(context, routes.TransactionList(f.name, categoryId: f.categoryId)),
        )).toList(),
      ),
    );
  }

  void _loadDetails() {
    presenter.loadExpense();
  }

  void onExpensesDetailLoaded(List<ExpenseEntity> value) {
    setState(() {
      homeEntities = value;
    });
  }

  void onDatabaseUpdate(String table) {
    _loadDetails();
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