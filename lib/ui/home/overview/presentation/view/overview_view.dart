import 'package:flutter/material.dart';

import 'package:my_wallet/ui/home/overview/presentation/presenter/overview_presenter.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;

class HomeOverview extends StatefulWidget {
  final TextStyle titleSTyle;

  HomeOverview(key, this.titleSTyle) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return HomeOverviewState();
  }
}

class HomeOverviewState extends State<HomeOverview> {

  final HomeOverviewPresenter _presenter = HomeOverviewPresenter();
  final NumberFormat nf = NumberFormat("\$#,##0.00");

  var _total = 0.0;

  void refresh() {
    _loadTotal();
  }

  void _loadTotal() {
    _presenter.loadTotal().then((value) {
      setState(() {
        _total = value;
      });
    });
  }
  @override
  void initState() {
    super.initState();

    _loadTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Overview", style: widget.titleSTyle,),
          Text("${nf.format(_total)}", style: Theme.of(context).textTheme.headline.apply(fontSizeFactor: 1.8, color: _total <= 0 ? theme.pinkAccent : theme.tealAccent),)
        ],
      ),
    );
  }
}