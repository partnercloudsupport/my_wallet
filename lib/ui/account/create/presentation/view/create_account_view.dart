import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:intl/intl.dart';

import 'package:my_wallet/ui/account/create/presentation/presenter/create_account_presenter.dart';

class CreateAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccount> {
  final CreateAccountPresenter _presenter = CreateAccountPresenter();

  AccountType _type = AccountType.Cash;
  String _name = "";

  GlobalKey<_AccountInitialAmountState> _accountAmountKey = GlobalKey();

  bool showNumberIputPad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Create Account",
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            onPressed: _saveAccount,
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              AccountTypeSelection(_type, _onTransactionTypeChanged),
              ListTile(
                title: TextField(
                  onChanged: _onAccountNameChanged,
                  onTap: () {
                    if(showNumberIputPad) {
                      setState(() {
                        showNumberIputPad = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Account Name",
                    hintStyle: Theme.of(context).textTheme.subhead.apply(color: theme.blueGrey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.darkBlue, width: 1.0)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.darkBlue, width: 1.0)),
                  ),
                ),
              ),
              _AccountInitialAmount(_accountAmountKey, _toggleNumberInputPad),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: showNumberIputPad ? NumberInputPad(_onAmountChanged, _accountAmountKey.currentState == null ? "" : _accountAmountKey.currentState._number, _accountAmountKey.currentState == null ? "" : _accountAmountKey.currentState._decimal) : null,
          )
        ],
      )
    );
  }

  void _saveAccount() {
    _presenter.saveAccount(_type, _name, _accountAmountKey.currentState._getAmount())
    .then((result) {
      Navigator.pop(context, result);
//    })
//    .catchError((e) {
//      showDialog(context: context, builder: (context) => AlertDialog(
//        title: Text("Error"),
//        content: Text(e.toString()),
//        actions: <Widget>[
//          FlatButton(
//            onPressed: () => Navigator.pop(context),
//            child: Text("OK"),
//          )
//        ],
//      ));
    });
  }

  void _onTransactionTypeChanged(AccountType type) {
    _type = type;
  }

  void _onAccountNameChanged(String name) {
    _name = name;
  }

  void _onAmountChanged(String number, String decimal) {
    _accountAmountKey.currentState.update(number, decimal);
  }

  void _toggleNumberInputPad() {
    setState(() {
      showNumberIputPad = !showNumberIputPad;
    });
  }
}

class _AccountInitialAmount extends StatefulWidget {
  final Function _onTap;

  _AccountInitialAmount(key, this._onTap) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AccountInitialAmountState();
  }
}

class _AccountInitialAmountState extends State<_AccountInitialAmount> {
  NumberFormat _nf = NumberFormat("#,##0.00");
  String _number;
  String _decimal;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("Initial Amount"),
          InkWell(
            child: Text(formatAmount(_number, _decimal), style: Theme.of(context).textTheme.title.apply(color: theme.darkBlue, fontSizeFactor: 1.5 ),),
            onTap: widget._onTap,
          )
        ],
      ),
    );
  }

  String formatAmount(String number, String decimal) {
    return "\$${_nf.format(_toNumber(number, decimal))}";
  }

  double _toNumber(String number, String decimal) {
    return double.parse("${number == null || number.isEmpty ? "0" : number}.${decimal == null || decimal.isEmpty ? "0" : decimal}");
  }

  double _getAmount() {
    return _toNumber(_number, _decimal);
  }

  void update(String number, String decimal) {
    setState(() {
      _number = number == null ? "" : number;
      _decimal = decimal == null ? "" : decimal;
    });
  }
}