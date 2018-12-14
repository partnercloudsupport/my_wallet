import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:flutter/cupertino.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

import 'package:flutter/scheduler.dart';

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

  final tables = [observer.tableAccount, observer.tableCategory, observer.tableUser];

  GlobalKey<NumberInputPadState> numPadKey = GlobalKey();
  /// to adjust the detail column/list base on screen height
  final minTextFactor = 0.9;
  final textFactorStep = 0.05;
  GlobalKey columnKey = GlobalKey();
  var itemCount = 0;
  var textFactor = 1.0;
  bool needList = false;
  var maxRowHeight = 0.0;
  /// END adjusting flexible column/list


  var _number = "";
  var _decimal = "";

  var _type = TransactionType.expenses;
  var _date = DateTime.now();

  Account _account;
  AppCategory _category;

  UserDetail _user;

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

    if(table == observer.tableTransactions || table == observer.tableUser) {
      if(widget.transactionId == null) {
        presenter.loadCurrentUserName();
      } else {
        presenter.loadTransactionDetail(widget.transactionId);
      }
    }
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) => _calculateColumnHeight());
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    presenter.loadAccounts();
    presenter.loadCategory();

    if(widget.transactionId != null) {
      presenter.loadTransactionDetail(widget.transactionId);
    } else {
      presenter.loadCurrentUserName();
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

    List<Widget> content = _detailContent();
    itemCount = content.length;

    return GradientScaffold(
      appBar: appBar,
      body: Column(
          children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: AppTheme.white,
                  child: needList ?
                      ListView(
                        shrinkWrap: true,
                        children: content,
                      )
                  :Column(
                    key: columnKey,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: content,
                  ),
                ),
              ),
            Align(
              child: NumberInputPad(numPadKey, _onNumberInput, _number, _decimal, showNumPad: true,),
              alignment: Alignment.bottomCenter,
            )
          ],
        ),
    );
  }

  List<Widget> _detailContent() {
    return <Widget> [
      ConversationRow(
        widget.transactionId == null ? "Create new" : "An",
        _type.name,
        AppTheme.darkBlue,
        onPressed: _showTransactionTypeSelection,
        onSizeChanged: _recalculateSize,
          textSizeFactor: textFactor),
      ConversationRow(
        widget.transactionId == null ? "of" : "valued of",
        _numberFormat.format(_toNumber(_number, _decimal)),
        TransactionType.isIncome(_type) ? AppTheme.tealAccent : TransactionType.isExpense(_type) ? AppTheme.pinkAccent : AppTheme.blueGrey,
        style: Theme.of(context).textTheme.display2,
        onSizeChanged: _recalculateSize,
          textSizeFactor: textFactor),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ConversationRow(
            "${widget.transactionId == null ? "" : "was made "}${TransactionType.isExpense(_type) ? "from" : TransactionType.isIncome(_type) ? "into" : "from"}",
            _account == null ? "Select Account" : _account.name,
            AppTheme.darkGreen,
            onPressed: _showSelectAccount,
            onSizeChanged: _recalculateSize,
              textSizeFactor: textFactor),
          ConversationRow(
            "by ",
            _user == null ? "Unknown" : _user.firstName,
            AppTheme.darkGreen,
            onSizeChanged: _recalculateSize,
              textSizeFactor: textFactor)
        ],
      ),
      ConversationRow(
        "for",
        _category == null ? "Select Category" : _category.name,
        AppTheme.brightPink,
        onPressed: _showSelectCategory,
        onSizeChanged: _recalculateSize,
          textSizeFactor: textFactor
      ),
      DateTimeRow(_date, _showDatePicker, _showTimePicker, onSizeChanged: _recalculateSize,
          textSizeFactor: textFactor),
    ];
  }

  void _recalculateSize(Size size) {
    if(size.height > maxRowHeight) {
      maxRowHeight = size.height;

      _calculateColumnHeight();
    }
  }

  void _calculateColumnHeight() {
    final columnContext = columnKey.currentContext;

    if(columnContext != null) {
      if(maxRowHeight*itemCount > columnContext.size.height) {
        if(textFactor <= minTextFactor) {
          needList = true;
          textFactor = 1.0;
        }
        else textFactor-= textFactorStep;

        setState(() {});
      }
    }
  }

  void _showTransactionTypeSelection() {
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
              child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkGreen), overflow: TextOverflow.ellipsis, maxLines: 1,) //Data(f.name, theme.darkGreen)
            ),
            onTap: () {
              setState(() => _account = f);

              Navigator.pop(context);
            },
          ),
        ),
        ),
    );
  }

  void _showSelectCategory() {
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(_categoryList, (f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
                child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.brightPink), overflow: TextOverflow.ellipsis, maxLines: 1,)
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
      _user = detail.user;

      _number = "${_nf.format(detail.amount)}";
      _decimal = "${_nf.format((detail.amount - detail.amount.floor()) * 100)}";
    });
  }

  @override
  void onLoadTransactionFailed(Exception e) {
  }

  @override
  void onUserDetailLoaded(UserDetail user) {
    setState(() => _user = user);
  }
}
