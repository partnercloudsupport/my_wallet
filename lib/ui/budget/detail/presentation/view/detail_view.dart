import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:intl/intl.dart';

class BudgetDetail extends StatefulWidget {
  final String title;
  final int categoryId;

  BudgetDetail(this.title, {this.categoryId});

  @override
  State<StatefulWidget> createState() {
    return _BudgetDetailState();
  }
}

class _BudgetDetailState extends CleanArchitectureView<BudgetDetail, BudgetDetailPresenter> implements BudgetDetailDataView, observer.DatabaseObservable {
  _BudgetDetailState() : super(BudgetDetailPresenter());

  var tables = [observer.tableCategory, observer.tableBudget];

  GlobalKey<NumberInputPadState> numPadKey = GlobalKey();

  String _number, _decimal;
  DateTime _from, _to;
  AppCategory _category;
  double _amount = 0.0;

  DateFormat _df = DateFormat("MMM, yyyy");
  NumberFormat _nf = NumberFormat("\$##0.00");

  List<AppCategory> _categories = [];

  void loadData() {
    presenter.loadCategoryList();

    if(widget.categoryId != null) {
      presenter.loadCategoryBudget(widget.categoryId);
    }
  }

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    loadData();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    _from = _to = DateTime.now();

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
                      "Create a budget for",
                      _category == null ? "Select Category" : _category.name,
                      AppTheme.pinkAccent,
                      onPressed: _onCategoryPressed,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ConversationRow(
                          "from",
                          _df.format(_from),
                          AppTheme.darkBlue,
                        ),
                        ConversationRow(
                          "to",
                          _df.format(_to),
                          AppTheme.darkBlue,
                        ),
                      ],
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
    presenter.saveBudget(
      _category,
      _amount,
      _from,
      _to
    );
  }

  @override
  void onSaveBudgetSuccess(bool result) {
    Navigator.pop(context);
  }

  @override
  void onSaveBudgetFailed(Exception e) {
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
}
