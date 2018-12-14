import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final ValueChanged<bool> onHighlightChanged;
  final ButtonTextTheme textTheme;
  final Color textColor;
  final Color disabledTextColor;
  final Color color;
  final Color disabledColor;
  final Color highlightColor;
  final Color splashColor;
  final Color sideColor ;
  final double sideWidth;
  final double radius;
  final Brightness colorBrightness;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;
  final MaterialTapTargetSize materialTapTargetSize;
  final Widget child;

  RoundedButton({Key key,
    @required this.onPressed,
    this.onHighlightChanged,
    this.textTheme,
    this.textColor,
    this.disabledTextColor,
    this.color,
    this.disabledColor,
    this.highlightColor,
    this.splashColor,
    this.sideColor = Colors.transparent,
    this.sideWidth = 0.0,
    this.radius = 20.0,
    this.colorBrightness,
    this.padding,
    this.clipBehavior = Clip.none,
    this.materialTapTargetSize,
    @required this.child,})
      : super(
      key: key);

  @override
  State<StatefulWidget> createState() {
    return RoundedButtonState();
  }
}

class RoundedButtonState extends State<RoundedButton> {

  var _processing = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        if(_processing) return;

        if(widget.onPressed != null) widget.onPressed();
      },
      onHighlightChanged: widget.onHighlightChanged,
      textTheme: widget.textTheme,
      textColor: widget.textColor,
      disabledColor: widget.disabledColor,
      color: widget.color,
        highlightColor: widget.highlightColor,
      splashColor: widget.splashColor,
      colorBrightness: widget.colorBrightness,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          side: BorderSide(color: widget.sideColor, width: widget.sideWidth)),
      padding: widget.padding,
      clipBehavior: widget.clipBehavior,
      materialTapTargetSize: widget.materialTapTargetSize,
      child: _processing ? SizedBox(
        width: 15.0,
        height: 15.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
        ),
      ) : widget.child,
    );
  }

  void process() => setState(() => _processing = true);
  void stop() => setState(() => _processing = false);
}
