import 'package:flutter/material.dart';

import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';
import 'package:my_wallet/ui/home/chart/saving/presentation/presenter/chart_saving_presenter.dart';
import 'package:intl/intl.dart';

class SavingChartView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SavingChartViewState();
  }
}

class _SavingChartViewState extends State<SavingChartView> {

  final SavingChartPresenter _presenter = SavingChartPresenter();
  final NumberFormat _nf = NumberFormat("\$#,##0.00");

  SavingEntity entity;

  @override
  void initState() {
    super.initState();

    _presenter.loadSaving()
    .then((value) {
      setState(() {
        entity = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: entity == null ? 0.0 : entity.fraction,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent),
                ),
              ),
            ),
          ),
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.pinkAccent, width: 3.0)),
              child: Text(entity == null ? "\$0.00" : _nf.format(entity.monthlySaving), style: Theme.of(context).textTheme.display2,)
          ),
        ],
      ),
    );
  }
}