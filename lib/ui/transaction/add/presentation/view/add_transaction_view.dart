import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:flutter/cupertino.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:intl/intl.dart';

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

  var _number = "";
  var _decimal = "";

  var _type = TransactionType.expenses;
  var _date = DateTime.now();

  GlobalKey _alertDialog = GlobalKey();
  bool _isSaving = false;

  Account _account;
  AppCategory _category;

  UserDetail _user;

  String _note;

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

    return GradientScaffold(
      appBar: appBar,
      body: Column(
          children: <Widget>[
          Expanded(
            child: Container(
              color: AppTheme.white,
              alignment: Alignment.center,
              child: FittedBox(
                child: Column(children: <Widget> [
                  ConversationRow(
                      widget.transactionId == null ? "Create new" : "An",
                      _type.name,
                      AppTheme.darkBlue,
                      onPressed: _showTransactionTypeSelection,
                  ),
                  ConversationRow(
                      widget.transactionId == null ? "of" : "valued of",
                      _numberFormat.format(_toNumber(_number, _decimal)),
                      TransactionType.isIncome(_type) ? AppTheme.tealAccent : TransactionType.isExpense(_type) ? AppTheme.pinkAccent : AppTheme.blueGrey,
                      style: Theme.of(context).textTheme.display2,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ConversationRow(
                          "${widget.transactionId == null ? "" : "was made "}${TransactionType.isExpense(_type) ? "from" : TransactionType.isIncome(_type) ? "into" : "from"}",
                          _account == null ? "Select Account" : _account.name,
                          AppTheme.darkGreen,
                          onPressed: _showSelectAccount,
                      ),
                      ConversationRow(
                          "by ",
                          _user == null ? "Unknown" : _user.firstName,
                          AppTheme.darkGreen,
                      )
                    ],
                  ),
                  ConversationRow(
                      "for",
                      _category == null ? "Select Category" : _category.name,
                      AppTheme.brightPink,
                      onPressed: _showSelectCategory,
                    trail: IconButton(
                      icon: Icon(_note == null || _note.isEmpty ? Icons.note_add : Icons.note, color: _note == null || _note.isEmpty ? AppTheme.darkGreen : AppTheme.pinkAccent,),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) => InputName(
                            "Enter Note",
                                (name) =>_note = name,
                            hintText: _note == null || _note.isEmpty ? "Add your Note" : _note,))),
                    )
                  ),
                  DateTimeRow(_date, _showDatePicker, _showTimePicker,),
                ],),
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
    showDatePicker(context: context, initialDate: _date, firstDate: _date.subtract(Duration(days: 365)), lastDate: _date.add(Duration(days: 365))).then((selected) {
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
    if(_isSaving) return;

    _isSaving = true;

    showDialog(context: context, builder: (_) => AlertDialog(
      key: _alertDialog,
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: Stack(
          children: <Widget>[
            Center(child: SizedBox(
              width: 200.0,
              height: 200.0,
              child: CircularProgressIndicator(),
            ),),
            Center(child: Text("Saving...", style: Theme.of(context).textTheme.title,),)
          ],
        ),
      ),
    ));

    presenter.saveTransaction(
      widget.transactionId,
        _type,
        _account,
        _category,
        _toNumber(_number, _decimal),
        _date,
        _note
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
    _dismissDialog();
    Navigator.pop(context);
  }

  @override
  void onSaveTransactionFailed(Exception e) {
    _dismissDialog();

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
      _note = detail.desc;

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

  void _dismissDialog() {
    if(_alertDialog.currentContext != null) {
      // alert dialog is showing
      Navigator.pop(context);
    }
  }
}
