import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';

class CardListTile extends Card {
  CardListTile({
    Key key,
    double elevation,
    EdgeInsets margin = const EdgeInsets.all(4.0),
    Clip clipBehavior = Clip.none,
    bool semanticContainer = true,
    String title,
    String subTitle,
    Function onTap,
    Widget trailing,
}) : super(
    key: key,
    elevation: elevation,
    clipBehavior: clipBehavior,
    semanticContainer: semanticContainer,
    color: Colors.white.withOpacity(0.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(width: 1.0, color: Colors.white)),
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(color: AppTheme.white),
      ),
      subtitle: subTitle == null || subTitle.isEmpty ? null : Text(subTitle),
      onTap: onTap,
      trailing: trailing,
    ),
  );
}