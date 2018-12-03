import 'package:flutter/material.dart';
import 'package:my_wallet/database/data.dart';

class TransactionDescription extends StatefulWidget {
  final ValueChanged<String> _onDescriptionChanged;
  final VoidCallback _onTapped;

  TransactionDescription(this._onDescriptionChanged, this._onTapped);

  @override
  State<StatefulWidget> createState() {
    return TransactionDescriptionState();
  }
}
class TransactionDescriptionState extends State<TransactionDescription> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 6,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          hintText: "Note",
          hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 18.0,
              fontWeight: FontWeight.bold
          ),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      onTap: widget._onTapped,
      onChanged: widget._onDescriptionChanged,
    );
  }
}