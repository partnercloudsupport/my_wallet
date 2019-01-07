import 'package:intl/intl.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:my_wallet/ui/home/expenseslist/data/expense_list_entity.dart';

import 'package:my_wallet/ui/home/expenseslist/presentation/presenter/expense_list_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/expenseslist/presentation/view/expese_list_dataview.dart';

class ExpensesListView extends StatefulWidget {
  ExpensesListView();

  @override
  State<StatefulWidget> createState() {
    return _ExpensesListViewState();
  }
}

class _ExpensesListViewState extends CleanArchitectureView<ExpensesListView, ExpensePresenter> implements observer.DatabaseObservable, ExpenseDataView {
  _ExpensesListViewState() : super(ExpensePresenter());

  final tables = [observer.tableTransactions, observer.tableCategory];
  final iconSize = 45.0;

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
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: homeEntities
            .map((f) => ListTile(
                 leading: Container(
                   width: iconSize,
                     height: iconSize,
                   child: Stack(
                     children: <Widget>[
                       Align(
                         alignment: Alignment.bottomCenter,
                         child: ClipRect(
                           child: Align(
                             alignment: Alignment.bottomCenter,
                             child: Icon(
                               Icons.monetization_on,
                               color: Color(AppTheme.hexToInt(f.colorHex)),
                               size: iconSize,),
                             heightFactor: f.remainFactor,
                           ),
                         ),
                       ),
                       Container(
                         alignment: Alignment.bottomCenter,
                         width: iconSize,
                         height: iconSize,
                         decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(color: Color(AppTheme.hexToInt(f.colorHex)), width: 1.0)
                         ),
                       )
                     ],
                   ),
                 ),
                  onTap: () => Navigator.pushNamed(context, routes.TransactionList(f.name, categoryId: f.categoryId)),
          title: Text(f.name, style: TextStyle(color: AppTheme.darkBlue),),
          trailing: Text(_nf.format(f.expense), style: TextStyle(color: AppTheme.darkBlue),),
                ))
            .toList(),
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
