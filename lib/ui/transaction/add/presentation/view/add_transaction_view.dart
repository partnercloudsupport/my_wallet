import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';

import 'package:my_wallet/ui/transaction/add/presentation/view/transaction_account.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/transaction_category_amount.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/transaction_description.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/transaction_date.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';

class AddTransaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTransactionState();
  }
}

class _AddTransactionState extends State<AddTransaction> {
  final AddTransactionPresenter _presenter = AddTransactionPresenter();

  TransactionType _type = TransactionType.expenses;

  GlobalKey<TransactionCategoryAndAmountState> _amountKey = GlobalKey<TransactionCategoryAndAmountState>();

  String _number = "";
  String _decimal = "";
  DateTime _date = DateTime.now();

  Account _account;
  AppCategory _category;
  String _desc;

  var _showNumPad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Create Transaction",
        actions: <Widget>[
          FlatButton(
            onPressed: _saveTransaction,
            child: Text("Save"),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SelectTransactionType(_type, _onTransactionTypeChanged),
                TransactionAccount(_type, _onAccountChanged),
                TransactionCategoryAndAmount(_amountKey, _type, _onCategoryTap, _toggleNumPad),
                TransactionDate(_date, _onDateChanged),
                TransactionDescription(_onDescriptionChanged, _dismissNumPad),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _showNumPad ? NumberInputPad(_onNumberInput, _number, _decimal) : null
            ),
          ],
        ),
      ),
    );
  }

  void _onTransactionTypeChanged(TransactionType type) {
    if(_amountKey.currentState != null) _amountKey.currentState.setType(type);

      _type = type;
  }

  void _onDateChanged(DateTime date) {
    _date = date;
  }

  void _onNumberInput(String number, String decimal) {
    _number = number;
    _decimal = decimal;

    _amountKey.currentState.setAmount(_toAmount(_number, _decimal));
  }

  void _toggleNumPad({bool state}) {
    setState(() {
      if (state == null) _showNumPad = !_showNumPad;
      else _showNumPad = state;
    });
  }
  void _dismissNumPad() {
    _toggleNumPad(state: false);
  }

  void _onAccountChanged(Account acc) {
    _account = acc;
  }

  void _onCategoryTap(AppCategory category) {
    _category = category;
  }

  void _onDescriptionChanged(String desc) {
    _desc = desc;
  }

  double _toAmount(String number, String decimal) {
    return double.parse("${number == null || number.isEmpty ? "0" : number}.${decimal == null || decimal.isEmpty ? "0" : decimal}");
  }

  void _saveTransaction() {
    _presenter.saveTransaction(
      _type,
      _account,
      _category,
      _toAmount(_number, _decimal),
      _date,
      _desc
    ).then((_) {
      Navigator.pop(context, true);
    }).catchError((e) {
      print(e.toString());
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(e.toString()),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ));
    });
  }
}