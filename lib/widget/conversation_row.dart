import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ConversationRow extends StatelessWidget {
  final String description;
  final String dataText;
  final Color dataColor;
  final Function onPressed;
  final TextStyle style;
  final Widget trail;

  ConversationRow(this.description, this.dataText, {this.dataColor = AppTheme.pinkAccent, this.onPressed, this.style, this.trail});

  @override
  Widget build(BuildContext context) {
    var children = trail == null
        ? <Widget>[
      _Description(description, ),
      _Data(dataText, dataColor, onPressed: onPressed, style: style, )
    ] :  <Widget>[
      _Description(description, ),
      _Data(dataText, dataColor, onPressed: onPressed, style: style, ),
      trail
    ];
    return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
    );
  }
}

class DateTimeRow extends StatelessWidget {
  final DateTime _date;

  final _dateFormat = DateFormat("dd MMM, yyyy");
  final _timeFormat = DateFormat("hh:mm a");

  final Function _onDatePressed;
  final Function _onTimePressed;

  DateTimeRow(this._date, this._onDatePressed, this._onTimePressed, );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Description("on", ),
          _Data(_dateFormat.format(_date), AppTheme.darkBlue, onPressed: _onDatePressed, maxFont: 25, minFont: 12, ),
          _Description("at", ),
          _Data(_timeFormat.format(_date), AppTheme.darkBlue, onPressed: _onTimePressed,maxFont: 25, minFont: 12, ),
        ],
      ),
    );
  }

}

class _Description extends StatelessWidget {
  final String _title;

  _Description(this._title,);

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        child: AutoSizeText(_title, style: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey,)),
        padding: EdgeInsets.all(8.0),
      );
  }
}

class _Data extends StatelessWidget {
  final String _data;
  final Color _color;
  final TextStyle style;
  final Function onPressed;
  final double maxFont;
  final double minFont;

  _Data(this._data, this._color, {this.style, this.onPressed, this.maxFont = 50, this.minFont = 12,});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: onPressed == null ? AutoSizeText(
        _data,
        style: style == null ? Theme.of(context).textTheme.title.apply(color: _color, ) : style.apply(color: _color, ),
        overflow: TextOverflow.ellipsis,)
          : FlatButton(
        onPressed: onPressed,
        child: AutoSizeText(
          _data,
          style: style == null ? Theme.of(context).textTheme.title.apply(color: _color, ) : style.apply(color: _color, ),
          maxFontSize: maxFont,
          minFontSize: minFont,
          maxLines: 1,) ,
      ),
    );
  }
}