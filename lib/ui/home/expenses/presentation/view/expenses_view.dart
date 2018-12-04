import 'package:flutter/material.dart';

import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/home/expenses/data/expenses_entity.dart';
import 'package:my_wallet/ui/home/expenses/presentation/presenter/expenses_presenter.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'dart:math';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';
import 'package:my_wallet/data_observer.dart' as observer;

class Expenses extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> implements observer.DatabaseObservable {
  final databaseWatch = [
    observer.tableCategory,
    observer.tableTransactions
  ];

  final ExpensesRepositoryPresenter _presenter = ExpensesRepositoryPresenter();

  List<ExpeneseEntity> _expensesList = [];
  
  var random = Random();

  void onDatabaseUpdate(String table) {
    _loadExpenses();
  }

  void _loadExpenses() {
    _presenter.loadExpenses().then((list) {
      setState(() {
        _expensesList = list == null ? [] : list;
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(databaseWatch, this);
    _loadExpenses();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(databaseWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    return _buildExpensesList();
  }

  Widget _buildExpensesList() {
    return Container(
      child: ListView.builder(
        itemCount: _expensesList.length,
        itemBuilder: (context, index) {
          return Container(
            child: ListTile(
              title: Text(_expensesList[index].name, style: TextStyle(color: theme.darkBlue),),
              leading: Icon(Icons.map, color: theme.darkBlue,),
              trailing: Text("\$${_expensesList[index].amount}", style: TextStyle(color: _expensesList[index].type == TransactionType.Expenses ? theme.pinkAccent : theme.tealAccent),),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionList("${_expensesList[index].name}", categoryId: _expensesList[index].categoryId,))),
            ),
            color: index % 2 == 0 ? Color(0xFFDADADA) : Colors.white,
          );
        },
        primary: false,
        shrinkWrap: true,
      ),
    );
  }
}
