import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';

typedef GetIndex<T> = int Function(T data);
typedef GetName<T> = String Function(T data);

class SelectTransactionType<T> extends StatefulWidget {
  final List<T> data;
  final T _type;
  final ValueChanged<T> _onChanged;
  final GetIndex<T> _getIndex;
  final GetName<T> _getName;

  SelectTransactionType(this.data, this._type, this._getIndex, this._getName, this._onChanged, {GlobalKey<TransactionTypeState<T>> key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TransactionTypeState<T>();
  }
}

class TransactionTypeState<T> extends State<SelectTransactionType<T>> with TickerProviderStateMixin {
  T _type;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _type = widget._type;
    _tabController = TabController(length: widget.data.length, vsync: this);

    _tabController.addListener(_onTabValueChanged);
    _tabController.index = widget._getIndex(_type);

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Container(
        child: TabBar(
          isScrollable: true,
          tabs: widget.data.map((f) => Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(widget._getName(f),
              style: TextStyle(color: _type == f ? Colors.white : AppTheme.darkBlue, fontSize: 16.0),),
          )).toList(),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppTheme.pinkAccent, //_type == TransactionType.Income ? theme.darkGreen : theme.pinkAccent,
          ),
          controller: _tabController,
        ),
      ),
    );
  }

  void _onTabValueChanged() {
    setState(() {
      _type = widget.data[_tabController.index];
    });
    widget._onChanged(_type);
  }

  void updateSelection(T selected) {
    setState(() {
      _type = selected;
      _tabController.animateTo(widget._getIndex(_type));
    });
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }
}