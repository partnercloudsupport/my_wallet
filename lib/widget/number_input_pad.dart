import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';

class NumberInputPad extends StatefulWidget {
  final Function(String, String) _onValueChanged;
  final String _number;
  final String _decimal;
  final bool showNumPad;

  NumberInputPad(GlobalKey<NumberInputPadState> key, this._onValueChanged, this._number, this._decimal, {this.showNumPad = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NumberInputPadState();
  }
}

class NumberInputPadState extends State<NumberInputPad> {
  String number = "";
  String decimal = "";
  bool isDecimal = false;

  bool _showNumPad = true;

  @override
  void initState() {
    super.initState();

    _showNumPad = widget.showNumPad;

    number = widget._number;
    decimal = widget._decimal;

    if(number == null) number = "";
    if(decimal == null) decimal = "";

    isDecimal = decimal.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    final numbers = [
      "1", "2", "3", "C",
      "4", "5", "6", "7",
      "8", "9", "0", "."];

    return Align(
      alignment: Alignment.bottomCenter,
      child: _showNumPad ? Container(
        decoration: BoxDecoration(
            gradient: AppTheme.bgGradient
        ),
        child: StaggeredGridView.countBuilder(
          shrinkWrap: true,
          primary: false,
          crossAxisCount: 4,
          itemCount: numbers.length,
          itemBuilder: (BuildContext context, int index) => _createButton(numbers[index], _onButtonClick),
          staggeredTileBuilder: (int index) => new StaggeredTile.count(_isDoubleWidth(index) ? 2 : 1, _isDoubleHeight(index) ? 3 : 1),
          crossAxisSpacing: 0.3,
        ),
      ) : null,
    );
  }

  Widget _createButton(String title, ValueChanged<String> f, {double width, double height}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.3),
//          color: theme.darkBlue
      ),
      child: FlatButton(onPressed: () => f(title), child: Text(title, style: TextStyle(fontSize: 24.0), textAlign: TextAlign.center,)),
    );
  }

  bool _isDoubleHeight(int index) {
    return index == 3;
  }

  bool _isDoubleWidth(int index) {
    return index == 10 || index == 11;
  }

  void _onButtonClick(String value) {
    switch (value) {
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
      case "0":
        if (isDecimal) {
          if (decimal.length < 2) decimal += value;
        } else {
          if (number.length < 12) number += value;
        }
        break;
      case "C":
        if (isDecimal && decimal.isNotEmpty)
          decimal = decimal.substring(0, decimal.length - 1);
        else if (number.isNotEmpty) {
          number = number.substring(0, number.length - 1);
          isDecimal = false;
        } else {
          isDecimal = false;
        }
        break;
      case ".":
        isDecimal = true;
        break;
    }

    widget._onValueChanged(number, decimal);
  }

  void toggleVisiblity() {
    if(_showNumPad) hide();
    else show();
  }

  void hide() {
    setState(() {
      _showNumPad = false;
    });
  }

  void show() {
    setState(() {
      _showNumPad = true;
    });
  }
}