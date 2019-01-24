import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:my_wallet/style/app_theme.dart';

typedef BuildWidget<T> = Widget Function(T);

class BottomViewContent<T> extends StatefulWidget {
  final List<T> _data;
  final BuildWidget _buildWidget;
  final Widget noDataDescription;

  BottomViewContent(this._data, this._buildWidget, {this.noDataDescription, GlobalKey<BottomViewContentState<T>>key}) : assert(_buildWidget != null), super(key : key);

  @override
  State<StatefulWidget> createState() {
    return BottomViewContentState<T>();
  }
}

class BottomViewContentState<T> extends State<BottomViewContent<T>> {
  List<T> _data;

  @override
  void initState() {
    super.initState();

    _data = widget._data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
      child: _data == null || _data.isEmpty
          ? widget.noDataDescription == null ? Text(
              "No data available.",
              style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue,),
              textAlign: TextAlign.center,)
          : widget.noDataDescription
          : ListView.builder(
          shrinkWrap: true,
          itemCount: _data == null ? 0 : _data.length,
          itemBuilder: (context, index) => widget._buildWidget(_data[index])
      ),
    );
  }

  void updateData(List<T> data) {
    setState(() => _data = data);
  }

//  static Widget count(BuildContext context, int count, Function(BuildContext, int) builder, {Widget noDataDescription}) {
//    return Container(
//      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
//      height: MediaQuery.of(context).size.height * 0.5,
//      alignment: Alignment.center,
//    child: count == 0
//        ? noDataDescription == null
//        ? Text("No data available", style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),)
//        : noDataDescription
//        : ListView.builder(
//          shrinkWrap: true,
//          itemCount: count,
//          itemBuilder: (context, index) => builder(context, index)
//      ),
//    );
//  }
}