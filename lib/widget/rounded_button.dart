import 'package:flutter/material.dart';

class RoundedButton extends FlatButton {
  RoundedButton({Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color highlightColor,
    Color splashColor,
    Color sideColor = Colors.transparent,
    double sideWidth = 0.0,
    double radius = 20.0,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    Clip clipBehavior = Clip.none,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget child})
      : super(
      key: key,
      onPressed: onPressed,
      onHighlightChanged: onHighlightChanged,
      textTheme: textTheme,
      textColor: textColor,
      disabledColor: disabledColor,
      color: color,
      highlightColor: highlightColor,
      splashColor: splashColor,
      colorBrightness: colorBrightness,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: sideColor, width: sideWidth)),
      padding: padding,
      clipBehavior: clipBehavior,
      materialTapTargetSize: materialTapTargetSize,
      child: child);
}
