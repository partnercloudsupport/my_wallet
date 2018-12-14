import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/scheduler.dart';

class ConversationRow extends StatelessWidget {
  final ValueChanged<Size> onSizeChanged;
  final String description;
  final String dataText;
  final Color dataColor;
  final Function onPressed;
  final TextStyle style;
  final double textSizeFactor;

  final GlobalKey rowKey = GlobalKey();

  ConversationRow(this.description, this.dataText, this.dataColor, {this.onPressed, this.style, this.onSizeChanged, this.textSizeFactor = 1.0}) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _calculateHeight());
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
          key: rowKey,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Description(description, textSizeFactor: textSizeFactor),
            _Data(dataText, dataColor, onPressed: onPressed, style: style, textSizeFactor: textSizeFactor)
          ],
        ),
    );
  }

  void _calculateHeight() {
    final rowContext = rowKey.currentContext;

    if(rowContext != null) {
      if(onSizeChanged != null) onSizeChanged(rowContext.size);
    }
  }
}

class DateTimeRow extends StatelessWidget {
  final ValueChanged<Size> onSizeChanged;
  final DateTime _date;
  final double textSizeFactor;

  final _dateFormat = DateFormat("dd MMM, yyyy");
  final _timeFormat = DateFormat("hh:mm a");

  final Function _onDatePressed;
  final Function _onTimePressed;

  DateTimeRow(this._date, this._onDatePressed, this._onTimePressed, {this.onSizeChanged, this.textSizeFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Description("on", textSizeFactor: textSizeFactor),
          _Data(_dateFormat.format(_date), AppTheme.darkBlue, onPressed: _onDatePressed, maxFont: 25, minFont: 12, textSizeFactor: textSizeFactor),
          _Description("at", textSizeFactor: textSizeFactor),
          _Data(_timeFormat.format(_date), AppTheme.darkBlue, onPressed: _onTimePressed,maxFont: 25, minFont: 12, textSizeFactor: textSizeFactor),
        ],
      ),
    );
  }

}

class _Description extends StatelessWidget {
  final String _title;
  final double textSizeFactor;

  _Description(this._title, {this.textSizeFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        child: AutoSizeText(_title, style: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey, fontSizeFactor: textSizeFactor)),
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
  final double textSizeFactor;

  _Data(this._data, this._color, {this.style, this.onPressed, this.maxFont = 50, this.minFont = 12, this.textSizeFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: onPressed == null ? Text(
        _data,
        style: style == null ? Theme.of(context).textTheme.title.apply(color: _color, fontSizeFactor: textSizeFactor) : style.apply(color: _color, fontSizeFactor: textSizeFactor),
        overflow: TextOverflow.ellipsis,)
          : FlatButton(
        onPressed: onPressed,
        child: AutoSizeText(
          _data,
          style: style == null ? Theme.of(context).textTheme.title.apply(color: _color, fontSizeFactor: textSizeFactor) : style.apply(color: _color, fontSizeFactor: textSizeFactor),
          maxFontSize: maxFont,
          minFontSize: minFont,
          maxLines: 1,) ,
      ),
    );
  }
}