import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/app_theme.dart' as theme;

class ConversationRow extends StatelessWidget {
  final String description;
  final String dataText;
  final Color dataColor;
  final Function onPressed;
  final TextStyle style;

  ConversationRow(this.description, this.dataText, this.dataColor, {this.onPressed, this.style});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Description(description),
          _Data(dataText, dataColor, onPressed: onPressed, style: style,)
        ],
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

  DateTimeRow(this._date, this._onDatePressed, this._onTimePressed);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Description("on"),
          _Data(_dateFormat.format(_date), theme.darkBlue, onPressed: _onDatePressed,),
          _Description("at"),
          _Data(_timeFormat.format(_date), theme.darkBlue, onPressed: _onTimePressed,),
        ],
      ),
    );
  }

}

class _Description extends StatelessWidget {
  final String _title;

  _Description(this._title);

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        child: Text(_title, style: Theme.of(context).textTheme.subhead.apply(color: theme.blueGrey)),
        padding: EdgeInsets.all(8.0),
      );
  }
}

class _Data extends StatelessWidget {
  final String _data;
  final Color _color;
  final TextStyle style;
  final Function onPressed;

  _Data(this._data, this._color, {this.style, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: onPressed == null ? Text(
        _data,
        style: style == null ? Theme.of(context).textTheme.title.apply(color: _color) : style.apply(color: _color),
        overflow: TextOverflow.ellipsis,)
          : FlatButton(
        onPressed: onPressed,
        child: Text(
          _data,
          style: style == null ? Theme.of(context).textTheme.title.apply(color: _color) : style.apply(color: _color),
          overflow: TextOverflow.ellipsis,) ,
      ),
    );
  }
}