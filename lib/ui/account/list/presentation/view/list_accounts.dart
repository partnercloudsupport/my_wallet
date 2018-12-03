import 'package:flutter/material.dart';

import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/ui/account/list/presentation/presenter/list_accounts_presenter.dart';
import 'package:my_wallet/routes.dart' as routes;

class ListAccounts extends StatefulWidget {
  final String _title;
  final bool selectionMode;

  ListAccounts(this._title, {this.selectionMode = false});

  @override
  State<StatefulWidget> createState() {
    return _ListAccountsState();
  }
}

class _ListAccountsState extends State<ListAccounts> {
  final ListAccountsPresenter _presenter = ListAccountsPresenter();
  var isEditMode = false;

  List<Account> _accounts = [];
  final NumberFormat _nf = NumberFormat("#,##0.00");

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
              onTap: () => widget.selectionMode ? Navigator.pop(context, _accounts[index]) : print("account ${_accounts[index].name} is tapped"),
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
    _presenter.loadAllAccounts()
        .then((value) {
      setState(() {
        _accounts = value;
      });
    });
  }

  void _deleteAccount(Account account) {
    _presenter.deleteAccount(account).then((result) {
      if(result) {
        _loadAllAccounts();
      }
    });
  }
}