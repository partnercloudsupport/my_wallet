import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

typedef BuildWidget<T> = Widget Function(T);

class BottomViewContent<T> extends StatelessWidget {
  final List<T> _data;
  final BuildWidget _buildWidget;

  BottomViewContent(this._data, this._buildWidget);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _data == null ? 0 : _data.length,
          itemBuilder: (context, index) => _buildWidget(_data[index])
      ),
    );
  }

  static Widget count(BuildContext context, int count, Function(BuildContext, int) builder) {
    var delegate = ListWheelChildBuilderDelegate(
      builder: builder,
      childCount: count
    );
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
//      child: ListWheelScrollView.useDelegate(
//        itemExtent: 20.0,
//          childDelegate: delegate,
//diameterRatio: 1.5,
//magnification: 1.5,
    child: ListView.builder(
          shrinkWrap: true,
          itemCount: count,
          itemBuilder: (context, index) => builder(context, index)
      ),
    );
  }
}