import 'package:flutter/material.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';
import 'package:my_wallet/data_observer.dart' as observer;
import 'package:flutter/cupertino.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/widget/number_input_pad.dart';
import 'package:my_wallet/widget/conversation_row.dart';

typedef BuildWidget<T> = Widget Function(T);

class AddTransaction extends StatefulWidget {
  final int transactionId;

  AddTransaction({this.transactionId});

  @override
  State<StatefulWidget> createState() {
    return _AddTransactionState();
  }
}

class _AddTransactionState extends CleanArchitectureView<AddTransaction, AddTransactionPresenter> implements AddTransactionDataView, observer.DatabaseObservable {
  _AddTransactionState() : super(AddTransactionPresenter());

  var _numberFormat = NumberFormat("\$#,##0.00");

  final tables = [observer.tableAccount, observer.tableCategory];

  var _number = "";
  var _decimal = "";

  var _type = TransactionType.expenses;
  var _date = DateTime.now();

  Account _account;
  AppCategory _category;

  List<Account> _accountList = [];
  List<AppCategory> _categoryList = [];

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

    observer.registerDatabaseObservable(tables, this);

    presenter.loadAccounts();
    presenter.loadCategory();

    if(widget.transactionId != null) {
      presenter.loadTransactionDetail(widget.transactionId);
    }
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);

    super.dispose();
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
                  ConversationRow(
                      widget.transactionId == null ? "Create new" : "An",
                      _type.name,
                      theme.darkBlue,
                      onPressed: _showTransactionTypeSelection),
                  ConversationRow(
                      widget.transactionId == null ? "of" : "valued of",
                      _numberFormat.format(_toNumber(_number, _decimal)),
                      TransactionType.isIncome(_type) ? theme.tealAccent : TransactionType.isExpense(_type) ? theme.pinkAccent : theme.blueGrey,
                      style: Theme.of(context).textTheme.display2),
                  ConversationRow(
                      "${widget.transactionId == null ? "" : "was made "}${TransactionType.isExpense(_type) ? "from" : TransactionType.isIncome(_type) ? "into" : "from"}",
                      _account == null ? "Select Account" : _account.name,
                      theme.darkGreen,
                    onPressed: _showSelectAccount,),
                  ConversationRow(
                    "for",
                      _category == null ? "Select Category" : _category.name,
                      theme.brightPink,
                      onPressed: _showSelectCategory
                  ),
                  DateTimeRow(_date, _showDatePicker, _showTimePicker)
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
        BottomViewContent(TransactionType.all, (f) =>
            Align(
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: theme.darkBlue))
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
        BottomViewContent(_accountList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
              child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: theme.darkGreen), overflow: TextOverflow.ellipsis, maxLines: 1,) //Data(f.name, theme.darkGreen)
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
        BottomViewContent(_categoryList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
                child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: theme.brightPink), overflow: TextOverflow.ellipsis, maxLines: 1,)
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
      if(selected != null) setState(() => _date = DateTime(selected.year, selected.month, selected.day, _date.hour, _date.minute, _date.second, _date.millisecond));
    });
  }

  void _showTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date)).then((selected) {
      if(selected != null) setState(() => _date = DateTime(_date.year, _date.month, _date.day, selected.hour, selected.minute, _date.second));
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
      widget.transactionId,
        _type,
        _account,
        _category,
        _toNumber(_number, _decimal),
        _date,
    );
  }

  @override
  void onAccountListLoaded(List<Account> value) {
    setState(() => this._accountList = value);
  }

  @override
  void onCategoryListLoaded(List<AppCategory> value) {
    setState(() => this._categoryList = value);
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

  @override
  void onLoadTransactionDetail(TransactionDetail detail) {
    setState(() {
      var _nf = NumberFormat("#");

      _type = detail.type;
      _date = detail.dateTime;
      _account = detail.account;
      _category = detail.category;

      _number = "${_nf.format(detail.amount)}";
      _decimal = "${_nf.format((detail.amount - detail.amount.floor()) * 100)}";
    });
  }

  @override
  void onLoadTransactionFailed(Exception e) {
  }
}

class BottomViewContent<T> extends StatefulWidget {
  final List<T> _data;
  final BuildWidget _buildWidget;

  BottomViewContent(this._data, this._buildWidget);

  @override
  State<StatefulWidget> createState() {
    return _BottomViewContentState<T>();
  }
}

class _BottomViewContentState<T> extends State<BottomViewContent> {
  List<T> data = [];

  @override
  void initState() {
    super.initState();

    data = widget._data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (context, index) => widget._buildWidget(data[index])
      ),
    );
  }
}