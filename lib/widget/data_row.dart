import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';

class DataRowView extends StatelessWidget {
  final String title;
  final String data;
  final Color color;
  final Function onPress;

  DataRowView(this.title, this.data, {this.color = AppTheme.darkBlue, this.onPress});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.title.apply(color: color),),
      trailing: Text(data, style: Theme.of(context).textTheme.body1.apply(color: color, fontSizeFactor: 1.2)),
      onTap: onPress,
    );
  }
}