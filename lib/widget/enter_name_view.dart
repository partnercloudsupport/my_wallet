import 'package:flutter/material.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'package:my_wallet/widget/scaffold.dart';

class InputName extends StatefulWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onNameChanged;
  final bool autoDismiss;

  InputName(this.title, this.onNameChanged, {this.hintText = "Enter a name", this.autoDismiss = true});

  @override
  State<StatefulWidget> createState() {
    return _InputNameState();
  }
}

class _InputNameState extends State<InputName> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: widget.title,
        actions: <Widget>[
          FlatButton(
            onPressed: _onNameSaved,
            child: Text("Save"),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        color: AppTheme.white,
        alignment: Alignment.topCenter,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey.withOpacity(0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.darkBlue, width: 1.0)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.darkBlue, width: 1.0)),
              contentPadding: EdgeInsets.all(8.0)
          ),
          style: Theme.of(context).textTheme.subhead.apply(color: AppTheme.darkBlue),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNameSaved() {
    widget.onNameChanged(_controller.text);

    Navigator.pop(context);
  }
}