import 'package:flutter/material.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/routes.dart' as routes;

class TransactionAccount extends StatefulWidget {
  final TransactionType _type;
  final ValueChanged<Account> _onAccountChanged;

  TransactionAccount(this._type, this._onAccountChanged);

  @override
  State<StatefulWidget> createState() {
    return _TransactionAccountState();
  }
}

class _TransactionAccountState extends State<TransactionAccount> {
  Account _account;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                child: Icon(Icons.data_usage, color: theme.darkBlue,),
                padding: EdgeInsets.all(10.0),
              ),
              Padding(
                child: Text(_account == null ? "Select Account" : _account.name, style: TextStyle(color: theme.darkBlue, fontSize: 20.0),),
                padding: EdgeInsets.all(10.0),
              )
            ],
          ),
          Icon(Icons.keyboard_arrow_right, color: theme.darkBlue,),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(context, routes.SelectAccount).then((value) {
          if (value != null) {
            setState(() {
              _account = value;
            });

            widget._onAccountChanged(_account);
          }
        });
      },
    );
  }
}