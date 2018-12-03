import 'package:flutter/material.dart';

import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/home/expenses/data/expenses_entity.dart';
import 'package:my_wallet/ui/home/expenses/presentation/presenter/expenses_presenter.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'dart:math';

class Expenses extends StatefulWidget {

  Expenses(key) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return ExpensesState();
  }
}

class ExpensesState extends State<Expenses> {
  ExpensesRepositoryPresenter _presenter = ExpensesRepositoryPresenter();

  List<ExpeneseEntity> _expensesList = [];
  
  var random = Random();

  void refresh() {
    _loadExpenses();
  }

  void _loadExpenses() {
    _presenter.loadExpenses().then((list) {
      setState(() {
        _expensesList = list;
      });
    })
        .catchError((error) {
      print(error.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
//    return Column(
//      mainAxisSize: MainAxisSize.max,
//      crossAxisAlignment: CrossAxisAlignment.end,
//      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//      children: <Widget>[
//        ChartRow(_expensesList),
//        _buildExpensesList(),
//      ],
//    );
    return _buildExpensesList();
  }

  Widget _buildExpensesList() {
    return Container(
      child: ListView.builder(
        itemCount: _expensesList.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: index % 2 == 0 ? Color(0xFFDADADA) : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(Icons.map, color: theme.darkBlue,),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _expensesList[index].name,
                          style:  TextStyle(
                              color: theme.darkBlue,
                              fontSize: 16.0
                          ),
                          textAlign: TextAlign.left,
                        ),
//                        Text("22 July 2018", style: TextStyle(
//                            color: theme.blueGrey,
//                            fontSize: 14.0
//                        ),)
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("\$${_expensesList[index].amount}", style: TextStyle(
                      color: _expensesList[index].type == TransactionType.Expenses ? theme.pinkAccent : theme.tealAccent,
                      fontSize: 16.0
                  ),),
                )
              ],
            ),
          );
        },
        primary: false,
        shrinkWrap: true,
      ),
    );
  }
}
