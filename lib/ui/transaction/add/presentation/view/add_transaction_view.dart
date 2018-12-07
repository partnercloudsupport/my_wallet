import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';
import 'package:my_wallet/data_observer.dart' as observer;
import 'package:flutter/cupertino.dart';

typedef BuildWidget<T> = Widget Function(T);

class AddTransaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTransactionState();
  }
}

class _AddTransactionState extends CleanArchitectureView<AddTransaction, AddTransactionPresenter> implements AddTransactionDataView, observer.DatabaseObservable {
  _AddTransactionState() : super(AddTransactionPresenter());

  final tables = [observer.tableAccount, observer.tableCategory];

  var _number = "";
  var _decimal = "";

  var _type = TransactionType.expenses;
  var _date = DateTime.now();

  var _nf = NumberFormat("\$#,##0.00");
  var _df = DateFormat("dd MMM, yyyy");
  var _tf = DateFormat("hh:mm a");

  Account _account;
  AppCategory _category;

  List<Account> accountList = [];
  List<AppCategory> categoryList = [];

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    if(table == observer.tableAccount) presenter.loadAccounts();

    if (table == observer.tableCategory) presenter.loadCategory();
  }

  @override
  void initState() {
    super.initState();

    presenter.loadAccounts();
    presenter.loadCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Create Transaction",
        actions: <Widget>[
          FlatButton(
            onPressed: _saveTransaction,
            child: Text("Save",),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Description("Create new"),
                        FlatButton(
                          onPressed: _showTransactionTypeSelection,
                          child: Data(_type.name, theme.darkBlue),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Description("of"),
                        Data(_nf.format(_toNumber(_number, _decimal)),TransactionType.isIncome(_type) ? theme.tealAccent : TransactionType.isExpense(_type) ? theme.pinkAccent : theme.blueGrey, style: Theme.of(context).textTheme.display2,),
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Description(TransactionType.isExpense(_type) ? "from" : TransactionType.isIncome(_type) ? "into" : "from"),
                        FlatButton(
                          onPressed: _showSelectAccount,
                          child: Data(_account == null ? "Select Account" : _account.name, theme.darkGreen),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Description("for"),
                        FlatButton(
                          onPressed: _showSelectCategory,
                          child: Data(_category == null ? "Select Category" : _category.name, theme.brightPink),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Description("on"),
                        FlatButton(
                          onPressed: _showDatePicker,
                          child: Data(_df.format(_date), theme.darkBlue),
                        ),
                        Description("at"),
                        FlatButton(
                          onPressed: _showTimePicker,
                          child: Data(_tf.format(_date), theme.darkBlue),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: NumberInputPad(_onNumberInput, _number, _decimal),
            )
          ],
        ),
    );
  }

  void _showTransactionTypeSelection() {
    showModalBottomSheet(context: context, builder: (context) =>
        _BottomViewContent(TransactionType.all, (f) =>
            Align(
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Data(f.name, theme.darkBlue)
                ),
                onTap: () {
                  setState(() => _type = f);

                  Navigator.pop(context);
                },
              ),
              alignment: Alignment.center,
            )
        )
    );
  }

  void _showSelectAccount() {
    showModalBottomSheet(context: context, builder: (context) =>
        _BottomViewContent(accountList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
              child: Data(f.name, theme.darkGreen)
            ),
            onTap: () {
              setState(() => _account = f);

              Navigator.pop(context);
            },
          ),
        ))
    );
  }

  void _showSelectCategory() {
    showModalBottomSheet(context: context, builder: (context) =>
        _BottomViewContent(categoryList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
                child: Data(f.name, theme.brightPink)
            ),
            onTap: () {
              setState(() => _category = f);

              Navigator.pop(context);
            },
          ),
        ))
    );
  }

  void _showDatePicker() {
    showDatePicker(context: context, initialDate: _date, firstDate: _date, lastDate: _date.add(Duration(days: 365))).then((selected) {
      setState(() => _date = DateTime(selected.year, selected.month, selected.day, _date.hour, _date.minute, _date.second, _date.millisecond));
    });
  }

  void _showTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date)).then((selected) {
      setState(() => _date = DateTime(_date.year, _date.month, _date.day, selected.hour, selected.minute, _date.second));
    });
  }

  void _onNumberInput(String number, String decimal) {
    setState(() {
      this._number = number;
      this._decimal = decimal;
    });
  }

  double _toNumber(String number, String decimal) {
    return double.parse("${number == null || number.isEmpty ? "0" : number}.${decimal == null || decimal.isEmpty ? "0" : decimal}");
  }

  void _saveTransaction() {
    presenter.saveTransaction(
        _type,
        _account,
        _category,
        _toNumber(_number, _decimal),
        _date,
    );
  }

  @override
  void onAccountListLoaded(List<Account> value) {
    setState(() => this.accountList = value);
  }

  @override
  void onCategoryListLoaded(List<AppCategory> value) {
    setState(() => this.categoryList = value);
  }

  @override
  void onSaveTransactionSuccess(bool result) {
    Navigator.pop(context, result);
  }

  @override
  void onSaveTransactionFailed(Exception e) {
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
  }
}

class Description extends StatelessWidget {
  final String _title;

  Description(this._title);

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        child: Text(_title, style: Theme.of(context).textTheme.subhead.apply(color: theme.blueGrey)),
        padding: EdgeInsets.all(8.0),
      );
  }
}

class Data extends StatelessWidget {
  final String _data;
  final Color _color;
  final TextStyle style;

  Data(this._data, this._color, {this.style});

  @override
  Widget build(BuildContext context) {
    return Text(_data, style: style == null ? Theme.of(context).textTheme.title.apply(color: _color) : style.apply(color: _color),);
  }
}

class _BottomViewContent<T> extends StatefulWidget {
  final List<T> _data;
  final BuildWidget _buildWidget;

  _BottomViewContent(this._data, this._buildWidget);

  @override
  State<StatefulWidget> createState() {
    return _BottomViewContentState<T>();
  }
}

class _BottomViewContentState<T> extends State<_BottomViewContent> {
  List<T> data = [];

  @override
  void initState() {
    super.initState();

    data = widget._data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (context, index) => widget._buildWidget(data[index])
      ),
    );
  }
}