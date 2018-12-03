import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ui/category/create/presentation/presenter/create_category_presenter.dart';

class CreateCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateCategoryState();
  }
}

class _CreateCategoryState extends State<CreateCategory> {
  TransactionType _type = TransactionType.Expenses;
  String _name = "";

  final CreateCategoryPresenter _presenter = CreateCategoryPresenter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Create Category",
        actions: <Widget>[
          FlatButton(
            onPressed: _saveCategory,
            child: Text("Save"),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SelectTransactionType(_type, _onTransactionChanged),
          ListTile(
            title: TextField(
              onChanged: _onNameChanged,
              decoration: InputDecoration(
                hintText: "Category Name",
                hintStyle: Theme.of(context).textTheme.subhead.apply(color: theme.blueGrey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.darkBlue, width: 1.0)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.darkBlue, width: 1.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    _presenter.saveCategory(_name, _type)
    .then((value) {
      Navigator.pop(context, value);
    })
    .catchError((e) {
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

  void _onTransactionChanged(TransactionType type) {
    _type = type;
  }

  void _onNameChanged(String name) {
    _name = name;
  }
}