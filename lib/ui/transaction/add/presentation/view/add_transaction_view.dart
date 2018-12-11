import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:flutter/cupertino.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

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

  GlobalKey<NumberInputPadState> numPadKey = GlobalKey();

  var _number = "";
  var _decimal = "";

  var _type = TransactionType.expenses;
  var _date = DateTime.now();

  Account _account;
  AppCategory _category;

  List<Account> _accountList = [];
  List<AppCategory> _categoryList = [];

  var keyboardSubscriptionId;

  @override
  void init() {
    presenter.dataView = this;

    keyboardSubscriptionId = KeyboardVisibilityNotification().addNewListener(onShow: () => setState(() => numPadKey.currentState.hide()));
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
    var appBar = MyWalletAppBar(
      title: "Create Transaction",
      actions: <Widget>[
        FlatButton(
          onPressed: _saveTransaction,
          child: Text("Save",),
        )
      ],
    );

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height - width - appBar.preferredSize.height - 23;

    return GradientScaffold(
      appBar: appBar,
      body: Stack(
          children: <Widget>[
            SizedBox(
              width: width,
              height: height,
              child: Container(
                color: AppTheme.white,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ConversationRow(
                          widget.transactionId == null ? "Create new" : "An",
                          _type.name,
                          AppTheme.darkBlue,
                          onPressed: _showTransactionTypeSelection),
                    ),
                    Expanded(
                      child: ConversationRow(
                        widget.transactionId == null ? "of" : "valued of",
                        _numberFormat.format(_toNumber(_number, _decimal)),
                        TransactionType.isIncome(_type) ? AppTheme.tealAccent : TransactionType.isExpense(_type) ? AppTheme.pinkAccent : AppTheme.blueGrey,
                        style: Theme.of(context).textTheme.display2,
                        onPressed: () => numPadKey.currentState.show(),),
                    ),
                    Expanded(
                      child: ConversationRow(
                        "${widget.transactionId == null ? "" : "was made "}${TransactionType.isExpense(_type) ? "from" : TransactionType.isIncome(_type) ? "into" : "from"}",
                        _account == null ? "Select Account" : _account.name,
                        AppTheme.darkGreen,
                        onPressed: _showSelectAccount,),
                    ),
                    Expanded(
                      child: ConversationRow(
                          "for",
                          _category == null ? "Select Category" : _category.name,
                          AppTheme.brightPink,
                          onPressed: _showSelectCategory
                      ),
                    ),
                    Expanded(
                      child: DateTimeRow(_date, _showDatePicker, _showTimePicker),
                    ),
                  ],
                ),
              ),
            ),
//            ),
            NumberInputPad(numPadKey, _onNumberInput, _number, _decimal, showNumPad: true,)
          ],
        ),
    );
  }

  void _showTransactionTypeSelection() {
    numPadKey.currentState.hide();

    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(TransactionType.all, (f) =>
            Align(
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue))
                ),
                onTap: () {
                  setState(() => _type = f);

                  Navigator.pop(context);

                  numPadKey.currentState.show();
                },
              ),
              alignment: Alignment.center,
            )
        )
    );
  }

  void _showSelectAccount() {
    numPadKey.currentState.hide();
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(_accountList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
              child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkGreen), overflow: TextOverflow.ellipsis, maxLines: 1,) //Data(f.name, theme.darkGreen)
            ),
            onTap: () {
              setState(() => _account = f);

              numPadKey.currentState.show();

              Navigator.pop(context);
            },
          ),
        ),
        ),
    );
  }

  void _showSelectCategory() {
    numPadKey.currentState.hide();
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(_categoryList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
                child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.brightPink), overflow: TextOverflow.ellipsis, maxLines: 1,)
            ),
            onTap: () {
              setState(() => _category = f);

              numPadKey.currentState.show();

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
