import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;

class TransactionDate extends StatefulWidget {
  final DateTime _date;
  final ValueChanged<DateTime> _onDateChanged;
  TransactionDate(this._date, this._onDateChanged);

  @override
  State<StatefulWidget> createState() {
    return _TransactionDateState();
  }
}
class _TransactionDateState extends State<TransactionDate> {
  DateFormat _dateFormatter = DateFormat("dd MMM, yyyy");
  DateTime _date;

  @override
  void initState() {
    _date = widget._date;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now().subtract(Duration(days: 365)), lastDate: DateTime.now().add(Duration(days: 3*365)))
                  .then((selected) {
                if (selected != null) {
                  setState(() {
                    _date = selected;
                  });

                  widget._onDateChanged(_date);
                }
              });
            },
            child: Text("${_dateFormatter.format(_date)}", style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold
            ),),
          ),

          IconButton(icon: Icon(Icons.category, color: theme.blueGrey,), onPressed: () {
            print("open category list");
          },)
        ],
      ),
    );
  }
}