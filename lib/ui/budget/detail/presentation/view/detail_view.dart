import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:my_wallet/ui/budget/budget_config.dart';

class BudgetDetail extends StatefulWidget {
  final String title;
  final int categoryId;
  final DateTime month;

  BudgetDetail(this.title, {this.categoryId, this.month});

  @override
  State<StatefulWidget> createState() {
    return _BudgetDetailState();
  }
}

class _BudgetDetailState extends CleanArchitectureView<BudgetDetail, BudgetDetailPresenter> implements BudgetDetailDataView, observer.DatabaseObservable {
  _BudgetDetailState() : super(BudgetDetailPresenter());

  var tables = [observer.tableCategory, observer.tableBudget];

  var _savingBudget = false;

  GlobalKey<NumberInputPadState> numPadKey = GlobalKey();
  GlobalKey alertDialog = GlobalKey();

  String _number, _decimal;
  DateTime _from, _to;
  AppCategory _category;
  double _amount = 0.0;

  NumberFormat _nf = NumberFormat("\$##0.00");

  List<AppCategory> _categories = [];

  void loadData() {
    presenter.loadCategoryList();

    if(widget.categoryId != null) {
      presenter.loadCategoryBudget(widget.categoryId, _from, _to);
    }
  }

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    if(_savingBudget) return;

    loadData();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    _from = _to = widget.month == null ? DateTime.now() : widget.month;

    loadData();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: widget.title,
        actions: <Widget>[
          FlatButton(
            onPressed: _saveBudget,
            child: Text("Save"),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: AppTheme.white,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                child: Column(
                  children: <Widget>[
                    ConversationRow(
                      "A monthly budget for",
                      _category == null ? "Select Category" : _category.name,
                      AppTheme.pinkAccent,
                      onPressed: _onCategoryPressed,
                    ),
                        ConversationRow(
                          "from",
                          df.format(_from),
                          AppTheme.darkBlue,
                          onPressed: _showFromMonth,
                        ),
                    ConversationRow(
                      "to",
                      df.format(_to),
                      AppTheme.darkBlue,
                      onPressed: _showToMonth,
                    ),
                    ConversationRow(
                      "at max",
                      _nf.format(_amount),
                      AppTheme.pinkAccent,
                      style: Theme.of(context).textTheme.display2,
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            child: NumberInputPad(
              numPadKey,
              _onNumberInput,
              _number,
              _decimal,
              showNumPad: true,
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }

  void _onCategoryPressed() {
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(_categories, (f) =>
            Align(
              child: InkWell(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue))
                ),
                onTap: () {
                  setState(() => _category = f);

                  Navigator.pop(context);
                },
              ),
              alignment: Alignment.center,
            )
        )
    );
  }

  void _showFromMonth() {
    showBottomSheetForMonths((date) {
      if(date.isAfter(_to)) _to = date;

      setState(() => _from = date);
      Navigator.pop(context);
    });
  }

  void _showToMonth() {
    showBottomSheetForMonths((date) {
      setState(() => _to = date);

      Navigator.pop(context);
    });
  }

  void showBottomSheetForMonths(ValueChanged<DateTime> onSelected) {
    showModalBottomSheet(
        context: context,
        builder: (_) => BottomViewContent.count(context, maxMonthSupport, (_, index) {
          var date = monthsAfter(DateTime.now(), index);

          return InkWell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(df.format(date), style: Theme.of(context).textTheme.headline.apply(color: AppTheme.darkBlue),),
              ),
            ),
            onTap: () => onSelected(date)
          );
        }));
  }
  void _onNumberInput(String number, String decimal) {
    setState(() {
      this._number = number;
      this._decimal = decimal;

      _amount = double.parse("${_number == null || _number.isEmpty ? "0" : _number}.${_decimal == null || _decimal.isEmpty ? "0" : _decimal}");
    });
  }

  @override
  void updateCategoryList(List<AppCategory> cats) {
    if(cats != null) setState(() => _categories = cats);
  }

  void _saveBudget() {
    if(_savingBudget) return;

    _savingBudget = true;

    showDialog(context: context, builder: (_) => AlertDialog(
      key: alertDialog,
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
    presenter.saveBudget(
      _category,
      _amount,
      _from,
      _to
    );
  }

  @override
  void onSaveBudgetSuccess(bool result) {
    dismissDialog();
    Navigator.pop(context);
  }

  @override
  void onSaveBudgetFailed(Exception e) {
    dismissDialog();

    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Failed to save budget"),
              content: Text("Failed to save budget with error ${e.toString()}"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Try Again"),
                )
              ],
            )
    );
  }

  @override
  void onBudgetLoaded(BudgetDetailEntity entity) {
    if(entity != null) {
      setState(() {
        this._to = entity.to;
        this._from = entity.from;
        this._amount = entity.amount;
        this._category = entity.category;
      });
    }
  }

  void dismissDialog() {
    if(alertDialog.currentContext != null) {
      // alert dialog is showing
      Navigator.pop(context);
    }
  }
}
