import 'package:my_wallet/ui/transaction/list/presentation/presenter/transaction_list_presenter.dart';
import 'package:my_wallet/ui/transaction/list/data/transaction_list_entity.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

class TransactionList extends StatefulWidget {
  final String title;
  final int accountId;
  final int categoryId;
  final DateTime day;

  TransactionList(this.title, {this.accountId, this.categoryId, this.day}) : super();

  @override
  State<StatefulWidget> createState() {
    return _TransactionListState();
  }
}

class _TransactionListState extends CleanArchitectureView<TransactionList, TransactionListPresenter> implements TransactionListDataView, observer.DatabaseObservable {
  _TransactionListState() : super(TransactionListPresenter());

  final _tables = [observer.tableTransactions, observer.tableUser];

  List<TransactionEntity> _entities = [];
  EventList _markedDates;
  DateTime _day;
  var _total = 0.0;
  var _fraction = 1.0;

  NumberFormat _nf = NumberFormat("\$#,##0.00");
  DateFormat _df = DateFormat("dd MMM, yyyy HH:mm:ss");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    _day = widget.day;

    if(_day == null) _day = DateTime.now();

    observer.registerDatabaseObservable(_tables, this);

    _loadData();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(_tables, this);
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: widget.title,
      ),
      body: ListView.builder(
          itemCount: _entities.length + 2,
          itemBuilder: (context, index) {
            if(index == 0) return Container(
              child: CalendarCarousel(
                onDayPressed: (day, events) {
                  setState(() => _day = day);
                  _loadData();
                },
                onCalendarChanged: (day) {
                  if(day.month == _day.month && day.year == day.year) {
                    // same month? load current selected day
                    _loadData();
                  } else {
                    // different, just load generic all data for the month 
                    _loadData(day: day);
                  }
                },
                selectedDateTime: _day,
                markedDatesMap: _markedDates,
//                markedDateIconBuilder: (data) => Align(
//                  child: FittedBox(
//                      child: Text("$data",
//                        style: Theme.of(context).textTheme.caption.apply(color: AppTheme.soulRed, fontSizeFactor: 0.8),
//                      overflow: TextOverflow.fade,)),
//                  alignment: Alignment.bottomCenter,),
//                markedDateShowIcon: true,
                weekendTextStyle: Theme.of(context).textTheme.title.apply(color: AppTheme.pinkAccent),
                height: 430.0,
                todayButtonColor: AppTheme.fadedRed,
              ),
            );

            if(index == 1) return Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(8.0),
              child: Text("TOTAL EXPENSES ${_nf.format(_total)}", style: TextStyle(color: AppTheme.darkBlue),),
              color: AppTheme.blueGrey.withOpacity(0.2),
            );

            var item = _entities[index - 2];

            return Container(
              child: ListTile(
                title: Text("${item.categoryName}${item.transactionDesc != null && item.transactionDesc.isNotEmpty ? " (${item.transactionDesc})" : ""}", style: Theme.of(context).textTheme.body2.apply(color: AppTheme.darkBlue),),
                leading: CircleAvatar(
                  child: Text(item.userInitial, style: Theme.of(context).textTheme.title.apply(color: AppTheme.white),),
                  backgroundColor: Color(item.userColor),
                ),
                subtitle: Text(_df.format(item.dateTime), style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),),
                trailing: Text("${_nf.format(item.amount)}", style: TextStyle(color: Color(item.transactionColor)),),
                onTap: () {
                  if(item.isUsualTransaction) Navigator.pushNamed(context, routes.EditTransaction(item.id));
                },
              ),
              color: index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.2),
            );
          }
      ),
    );
  }

  @override
  void onTransactionListLoaded(TransactionListEntity list) {
    setState(() {
      this._entities = list.entities;
      this._total = list.total;
      this._fraction = list.fraction;

      if(list.dates != null || list.dates.isNotEmpty) {
        Map<DateTime, List<String>> events = {};
        list.dates.forEach((date, spent) => events.putIfAbsent(date, () => [_nf.format(spent)]));

        this._markedDates = EventList(
            events: events
        );
      } else {
        this._markedDates = null;
      }
    });
  }

  @override
  void onDatabaseUpdate(String table) {
    _loadData();
  }

  void _loadData({DateTime day}) {
    presenter.loadDataFor(widget.accountId, widget.categoryId, day == null ? _day : day);
  }
}
