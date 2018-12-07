import 'package:flutter/material.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter/widgets.dart';

class MyWalletAppBar extends GradientAppBar {
    MyWalletAppBar(
      {String title,
        String subTitle,
        List<Widget> actions,
        Widget leading}) : super(
    title: subTitle == null ? Text("$title", style: TextStyle(color: theme.white),)
        : Column(
      children: <Widget>[
        Text("$title", style: TextStyle(color: theme.white),),
        Text("$subTitle", style: TextStyle(color: theme.white, fontSize: 14.0),)
      ],
    ),
    actions: actions,
    centerTitle: true,
    leading: leading,
    backgroundColorStart: theme.darkBlue,
    backgroundColorEnd: theme.darkBlue.withOpacity(0.8));
}
//class MyWalletAppBar extends AppBar {
//  MyWalletAppBar(
//      {String title,
//        String subTitle,
//        List<Widget> actions,
//        Widget leading}) : super(
//    title: subTitle == null ? Text("$title", style: TextStyle(color: Colors.white),)
//        : Column(
//      children: <Widget>[
//        Text("$title", style: TextStyle(color: Colors.white),),
//        Text("$subTitle", style: TextStyle(color: Colors.white, fontSize: 14.0),)
//      ],
//    ),
//    actions: actions,
//    backgroundColor: theme.darkBlue,
//    centerTitle: true,
//    leading: leading,);
//}
//
class MyWalletSliverAppBar extends SliverAppBar {
  MyWalletSliverAppBar(
      {String title,
        String subTitle,
        List<Widget> actions,
        Widget leading}
      ) : super(
      title: Text("$title", style: TextStyle(color: Colors.white),),
      actions: actions,
      leading: leading
  );
}