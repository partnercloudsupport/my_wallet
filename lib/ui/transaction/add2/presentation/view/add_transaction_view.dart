import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;

class AddTransaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTransactionState();
  }
}

enum _Pages {
  SelectTransactionType,
  SelectCategory,
  SelectAccount,
  EnterAmount,
  Review
}

class _AddTransactionState extends State<AddTransaction> {
  var _number = "";
  var _decimal = "";

  var _type = TransactionType.expenses;
  var _showNumPad = false;

  var _nf = NumberFormat("\$#,##0.00");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Create Transaction",
      ),
      body: PageView.builder(
          itemCount: _Pages.values.length,
          itemBuilder: _buildPages)
    );
  }

  Widget _buildPages(BuildContext context, int index) {
    _Pages page = _Pages.values[index];
    switch(page) {
      case _Pages.SelectTransactionType: break;
      case _Pages.SelectCategory: break;
      case _Pages.SelectAccount: break;
      case _Pages.EnterAmount: break;
      case _Pages.Review: break;
    }
  }
}