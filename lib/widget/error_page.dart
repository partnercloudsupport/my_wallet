import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'package:my_wallet/widget/rounded_button.dart';

class ErrorPage extends StatefulWidget {
  final String _errorText;
  final Function _retry;

  ErrorPage(key, this._errorText, this._retry) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ErrorPageState();
  }
}

class ErrorPageState extends State<ErrorPage> {
  final GlobalKey<RoundedButtonState> _retryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/nartus.png", fit: BoxFit.fitWidth, scale: 0.8,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget._errorText,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.darkBlue),
            ),
          ),
          Opacity(
            opacity: 1.0,
            child: RoundedButton(
              key: _retryKey,
              onPressed: () {
                if(_retryKey.currentContext != null) _retryKey.currentState.process();
                widget._retry();
              },
              child: Padding(padding: EdgeInsets.all(12.0), child: Text("Try Again", style: TextStyle(color: AppTheme.white),),),
              color: AppTheme.pinkAccent,),)
        ],
      );
  }

  void stopRetry() {
    if(_retryKey.currentContext != null) _retryKey.currentState.stop();
  }
}