import 'package:charts_flutter/flutter.dart';
import 'package:my_wallet/ui/home/chart/transactions/data/transaction_entity.dart';
import 'package:my_wallet/ui/home/chart/transactions/presentation/presenter/transaction_presenter.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/chart/transactions/presentation/view/chart_transaction_dataview.dart';
import 'package:my_wallet/data/data.dart';

class TransactionChart extends StatefulWidget {
  final List<TransactionType> _type;

  TransactionChart(this._type);

  @override
  State<StatefulWidget> createState() {
    return _TransactionChartState();
  }
}

class _TransactionChartState extends CleanArchitectureView<TransactionChart, TransactionPresenter> implements observer.DatabaseObservable, TransactionDataView {

  _TransactionChartState() : super(TransactionPresenter());

  final databaseWatch = [
    observer.tableTransactions,
    observer.tableCategory
  ];

  List<TransactionEntity> transactions = [];

  @override
  void init() {
    presenter.dataView = this;
  }
  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(databaseWatch, this);
    _loadTransaction();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(databaseWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    return transactions == null || transactions.isEmpty
        ? Center(child: Text("No Transaction found", style: Theme.of(context).textTheme.title,),)
        : PieChart([
          Series<TransactionEntity, double>(
              id: "_transactions",
              data: transactions,
              measureFn: (data, index) => data.amount,
              domainFn: (data, index) => data.amount,
              colorFn: (data, index) => Color.fromHex(code: data.color),
              labelAccessorFn: (data, index) => "${data.category}",
          ),
    ],
      animate: false,
      defaultRenderer: ArcRendererConfig(
          arcRendererDecorators: [ ArcLabelDecorator(
            labelPosition: ArcLabelPosition.outside,
            outsideLabelStyleSpec: TextStyleSpec(
                color: Color.fromHex(code: "#FFFFFF"),
                fontSize: 14
            ),
            insideLabelStyleSpec: TextStyleSpec(
                color: Color.fromHex(code: "#FFFFFF"),
                fontSize: 14
            ),
            leaderLineStyleSpec: ArcLabelLeaderLineStyleSpec(
              color: Color.fromHex(code: "#FFFFFF"),
              thickness: 2.0,
              length: 24.0
            ),
          ) ]
      ),
    );
  }

  void onDatabaseUpdate(String table) {
    _loadTransaction();
  }

  void _loadTransaction() {
    presenter.loadTransaction(widget._type);
  }

  void onTransactionListLoaded(List<TransactionEntity> list) {
    if(this.mounted)
      setState(() {
        this.transactions = list;
      });
  }
}

class ExpenseChart extends TransactionChart {
  ExpenseChart() : super(TransactionType.typeExpense);
}

class IncomeChart extends TransactionChart {
  IncomeChart() : super(TransactionType.typeIncome);
}