import 'package:flutter/material.dart';

import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/ui/account/list/presentation/presenter/list_accounts_presenter.dart';
import 'package:my_wallet/routes.dart' as routes;
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
    return Scaffold(
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
      body: ListView.builder(
          itemCount: _accounts.length,
          itemBuilder: (context, index) => Container(
            child: ListTile(
              title: Text(_accounts[index].name, style: TextStyle(fontSize: 18.0, color: theme.darkBlue),),
              subtitle: Text("${_nf.format(_accounts[index].balance)}"),
              trailing: isEditMode ? IconButton(
                onPressed: () {
                  _deleteAccount(_accounts[index]);
                },
                icon: Icon(Icons.close, color: theme.pinkAccent,),
              ) : null,
              onTap: () => widget.selectionMode ? Navigator.pop(context, _accounts[index]) : Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionList(_accounts[index].name, accountId: _accounts[index].id,))),
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.blueGrey)),
            ),
          )
      ),
      floatingActionButton: isEditMode ? RaisedButton(onPressed: () => Navigator.pushNamed(context, routes.AddAccount)
          .then((value) {
            if(value != null) _loadAllAccounts();
          }),
        child: Text(("Create Account"),),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        color: theme.pinkAccent,) : null,
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