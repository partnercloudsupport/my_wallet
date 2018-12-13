import 'package:my_wallet/data/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/ui/account/list/presentation/presenter/list_accounts_presenter.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/account/list/presentation/view/list_account_dataview.dart';

class ListAccounts extends StatefulWidget {
  final String _title;
  final bool selectionMode;

  ListAccounts(this._title, {this.selectionMode = false});

  @override
  State<StatefulWidget> createState() {
    return _ListAccountsState();
  }
}

class _ListAccountsState extends CleanArchitectureView<ListAccounts, ListAccountsPresenter> implements ListAccountDataView {
  _ListAccountsState() : super(ListAccountsPresenter());

  var isEditMode = false;

  List<Account> _accounts = [];
  final NumberFormat _nf = NumberFormat("#,##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    _loadAllAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: widget._title,
        actions: <Widget>[
          FlatButton(
            child: Text(isEditMode ? "Done" : "Edit"),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
        leading: isEditMode ? Text("", style: TextStyle(color: Colors.transparent),) : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
            itemCount: _accounts.length,
            itemBuilder: (context, index) => CardListTile(
              title: _accounts[index].name,
                onTap: () => widget.selectionMode ? Navigator.pop(context, _accounts[index]) : Navigator.pushNamed(context,
                    routes.TransactionList(_accounts[index].name, accountId: _accounts[index].id)),
              subTitle: "${_nf.format(_accounts[index].balance)}",
              trailing: isEditMode ? IconButton(
                onPressed: () {
                  _deleteAccount(_accounts[index]);
                },
                icon: Icon(Icons.close, color: AppTheme.pinkAccent,),
              ) : null,
            )
        ),
      ),
      floatingActionButton: isEditMode ? RoundedButton(onPressed: () => Navigator.pushNamed(context, routes.AddAccount)
          .then((value) {
            if(value != null) _loadAllAccounts();
          }),
        child: Text(("Create Account"),),
        color: AppTheme.pinkAccent,) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _loadAllAccounts() {
    presenter.loadAllAccounts();
  }

  void onAccountListLoaded(List<Account> acc) {
    setState(() {
      _accounts = acc;
    });
  }

  void _deleteAccount(Account account) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Delete account ${account.name}"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            child: Icon(Icons.warning, color: Colors.yellow, size: 36.0,),
            padding: EdgeInsets.all(10.0),
          ),
          Flexible(
            child: Text("Warning: All transactions related to this account will be remove. Are you sure to delete this account?"),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Delete"),
          onPressed: () {
            Navigator.pop(context);

            presenter.deleteAccount(account);
          },
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ));
  }
}