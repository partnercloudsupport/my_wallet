import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/account/liability/detail/presentation/presenter/liability_presenter.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:intl/intl.dart';

class LiabilityView extends StatefulWidget {
  final int _id;
  final String _name;

  LiabilityView(this._id, this._name);

  @override
  State<StatefulWidget> createState() {
    return _LiabilityState();
  }
}

class _LiabilityState extends CleanArchitectureView<LiabilityView, LiabilityPresenter> implements LiabilityDataView, observer.DatabaseObservable {
  _LiabilityState() : super(LiabilityPresenter());

  final _tables = [observer.tableAccount, observer.tableTransactions];
  final _nf = NumberFormat("\$#,###.##");
  final _df = DateFormat("dd MMM, yyyy HH:mm");

  Account _account;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    _loadData();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(_tables, this);

    _loadData();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(_tables, this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: _account == null ? widget._name : _account.name,
      ),
      body: Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: ListView(
            children: <Widget>[
              DataRowView("Account", _account == null ? "" : _account.name),
              DataRowView("Created", _account == null ? "" : _df.format(_account.created)),
              DataRowView("Type", _account == null ? "" : _account.type.name),
              DataRowView("Total Liability", _account == null ? "" : _nf.format(_account.initialBalance)),
              DataRowView("Balance", _account == null ? "" : _nf.format(_account.balance)),
              RoundedButton(
                onPressed: () {
                  if(_account != null) Navigator.pushNamed(context, routes.TransactionList(_account.name, accountId: _account.id));
                },
                child: Padding(padding: EdgeInsets.all(12.0), child: Text("View Transactions", style: TextStyle(color: AppTheme.white),),),
                color: AppTheme.blue,
              ),
              RoundedButton(
                onPressed: () {
                  if(_account != null) Navigator.pushNamed(context, routes.PayLiability(accountName: _account.name, accountId: _account.id));
                },
                child: Padding(padding: EdgeInsets.all(12.0), child: Text("Make a payment", style: TextStyle(color: AppTheme.white),),),
                color: AppTheme.blue,
              ),
            ],
          )
      ),
    );
  }

  void _loadData() {
    presenter.loadAccountInfo(widget._id);
  }

  @override
  void onAccountLoaded(Account acc) {
    setState(() => _account = acc);
  }

  @override
  void onAccountLoadError(Exception e) {

  }
}