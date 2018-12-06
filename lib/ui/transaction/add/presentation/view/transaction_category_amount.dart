import 'package:flutter/material.dart';
import 'package:my_wallet/database/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/routes.dart' as routes;

class TransactionCategoryAndAmount extends StatefulWidget {
  final TransactionType _type;
  final ValueChanged<AppCategory> _onCategoryChanged;
  final Function _onAmountTap;

  TransactionCategoryAndAmount(key, this._type, this._onCategoryChanged, this._onAmountTap) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TransactionCategoryAndAmountState();
  }
}
class TransactionCategoryAndAmountState extends State<TransactionCategoryAndAmount> {
  TransactionType _type;
  NumberFormat _numberFormat = NumberFormat("\$#,##0.00");
  double _amount = 0;

  AppCategory _category;

  @override
  void initState() {
    super.initState();

    _type = widget._type;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: FlatButton(
            child: Text(_category == null ? "Select Category" : _category.name,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: _category == null ? Colors.black : Color(theme.hexToInt(_category.colorHex)),
                  fontSize: 20.0
              ),),
            onPressed: () {
              Navigator.pushNamed(context, routes.SelectCategory).then((value) {
                if(value != null) {
                  setState(() {
                    _category = value;
                  });
                  widget._onCategoryChanged(_category);
                }
              });
            },
          ),
        ),
        Flexible(
          child: FlatButton(
            child: Text(
              "${_numberFormat.format(_amount)}",
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: TransactionType.isIncome(_type) ? theme.darkGreen : theme.pinkAccent,
                fontSize: 20.0,
              ),
            ),
            onPressed: widget._onAmountTap,
          ),
        )
      ],
    );
  }

  void setAmount(double amount) {
    setState(() {
      _amount = amount;
    });
  }

  void setType(TransactionType type) {
    setState(() {
      _type = type;
    });
  }
}