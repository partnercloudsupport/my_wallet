import 'package:flutter/material.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/app_theme.dart' as theme;

class SelectTransactionType extends StatefulWidget {
  final TransactionType _type;
  final ValueChanged<TransactionType> _onChanged;

  SelectTransactionType(this._type, this._onChanged);

  @override
  State<StatefulWidget> createState() {
    return _TransactionTypeState();
  }
}

class _TransactionTypeState extends State<SelectTransactionType> with TickerProviderStateMixin {
  TransactionType _type;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _type = widget._type;
    _tabController = TabController(length: TransactionType.all.length, vsync: this);

    _tabController.addListener(_onTabValueChanged);
    _tabController.index = _type.id;

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Container(
        child: TabBar(
          isScrollable: true,
          tabs: TransactionType.all.map((f) => Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(f.name,
              style: TextStyle(color: _type == f ? Colors.white : theme.darkBlue, fontSize: 16.0),),
          )).toList(),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: theme.pinkAccent, //_type == TransactionType.Income ? theme.darkGreen : theme.pinkAccent,
          ),
          controller: _tabController,
        ),
      ),
    );
  }

  void _onTabValueChanged() {
    setState(() {
      _type = TransactionType.all[_tabController.index];
    });
    widget._onChanged(_type);
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }
}