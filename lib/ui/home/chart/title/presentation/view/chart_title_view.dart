import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';
import 'package:my_wallet/ui/home/chart/title/presentation/presenter/chart_title_presenter.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/home/chart/title/presentation/view/chart_title_data_view.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ChartTitleView extends StatefulWidget {
  final TabController _controller;
  final double height;

  ChartTitleView(this._controller, {this.height});

  @override
  State<StatefulWidget> createState() {
    return _ChartTitleViewState();
  }
}

class _ChartTitleViewState extends CleanArchitectureView<ChartTitleView, ChartTitlePresenter> implements observer.DatabaseObservable, ChartTitleDataView {
  _ChartTitleViewState() : super(ChartTitlePresenter());

  final tableWatch = [
    observer.tableTransactions
  ];

  ChartTitleEntity entity;
  NumberFormat _nf = NumberFormat("\$#,##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tableWatch, this);

    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(tableWatch, this);
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.title;
    var subTitleStyle = textStyle.apply(fontSizeFactor: 0.7, color: AppTheme.white);

    return TabBar(
              tabs: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AutoSizeText(
                        "Income",
                        style: textStyle.apply(color: AppTheme.tealAccent),
                        maxLines: 1,
                      ),
                      Text("${entity == null ? "\$0.00" : _nf.format(entity.incomeAmount)}", style: subTitleStyle,)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AutoSizeText(
                        "Expense",
                        style: textStyle.apply(color: AppTheme.pinkAccent),
                        maxLines: 1,
                      ),
                      Text("${entity == null ? "\$0.00" : _nf.format(entity.expensesAmount)}", style: subTitleStyle,)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AutoSizeText("Saving",
                      style: textStyle.apply(color: AppTheme.brightGreen),
                        maxLines: 1,
                      ),
                      Text("${entity == null ? "\$0.00" : _nf.format(entity.savingAmount)}", style: subTitleStyle,)
                    ],
                  ),
                )
              ],
              controller: widget._controller,
              indicatorWeight: 4.0,
              indicatorColor: Colors.white.withOpacity(0.8),
            );
  }

  void _loadDetails() {
    presenter.loadTitleDetail();
  }

  void onDetailLoaded(ChartTitleEntity value) {
    setState(() {
      entity = value;
    });
  }

  void onDatabaseUpdate(String table) {
    _loadDetails();
  }
}