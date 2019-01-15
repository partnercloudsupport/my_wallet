import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/app_material.dart';
import 'package:my_wallet/ui/account/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/account/detail/presentation/view/detail_data_view.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:my_wallet/style/routes.dart';
import 'package:intl/intl.dart';

class AccountDetail extends StatefulWidget {
  final int _accountId;
  final String _name;

  AccountDetail(this._accountId, this._name);

  @override
  State<StatefulWidget> createState() {
    return _AccountDetailState();
  }
}

class _AccountDetailState extends CleanArchitectureView<AccountDetail, AccountDetailPresenter> implements AccountDetailDataView, observer.DatabaseObservable {
  _AccountDetailState() : super(AccountDetailPresenter());

  final _tables = [observer.tableAccount];
  final _nf = NumberFormat("\$#,###.##");
  final _df = DateFormat("dd MMM, yyyy HH:mm");

  Account _account;

  @override
  void init() {
    presenter.dataView = this;
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
        title: widget._name,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: ListView(
          children: <Widget>[
            DataRowView("Account", _account == null ? "" : _account.name),
            DataRowView("Created", _account == null ? "" : _df.format(_account.created)),
            DataRowView("Type", _account == null ? "" : _account.type.name),
            DataRowView("Balance", _account == null ? "" : _nf.format(_account.balance)),
            DataRowView("Spent", _account == null ? "" : _nf.format(_account.spent)),
            DataRowView("Earned", _account == null ? "" : _nf.format(_account.earn)),
            RoundedButton(
              onPressed: () {
                if(_account != null) Navigator.pushNamed(context, routes.TransactionList(_account.name, accountId: _account.id));
              },
              child: Padding(padding: EdgeInsets.all(12.0), child: Text("View Transactions", style: TextStyle(color: AppTheme.white),),),
              color: AppTheme.blue,
            ),
          ],
        )
      ),
    );
  }

  void onDatabaseUpdate(String table) {
    _loadData();
  }

  void _loadData() {
    presenter.loadAccount(widget._accountId);
  }

  @override
  void onAccountLoaded(Account account) {
    setState(() => _account = account);
  }

  @override
  void failedToLoadAccount(Exception ex) {
    print("Error $ex");
  }
}
