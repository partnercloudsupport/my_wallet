import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter/widgets.dart';

class MyWalletAppBar extends GradientAppBar {
    MyWalletAppBar(
      {String title,
        String subTitle,
        List<Widget> actions,
        Widget leading}) : super(
    title: subTitle == null ? Text("$title", style: TextStyle(color: AppTheme.white),)
        : Column(
      children: <Widget>[
        Text("$title", style: TextStyle(color: AppTheme.white),),
        Text("$subTitle", style: TextStyle(color: AppTheme.white, fontSize: 14.0),)
      ],
    ),
    actions: actions,
    centerTitle: true,
    leading: leading,
    backgroundColorStart: AppTheme.bgGradient.colors[0],
    backgroundColorEnd: AppTheme.bgGradient.colors[1]);
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
//class MyWalletSliverAppBar extends SliverAppBar {
//  MyWalletSliverAppBar(
//      {String title,
//        String subTitle,
//        List<Widget> actions,
//        Widget leading,
//      double expandedHeight,
//      bool pinned,
//      Widget flexibleSpace}
//      ) : super(
//      title: Container(
//        child: Text("$title", style: TextStyle(color: Colors.white),),
//        decoration: BoxDecoration(
//          gradient: AppTheme.bgGradient
//        ),
//      ),
//      actions: actions,
//      leading: leading,
//      expandedHeight: expandedHeight,
//      pinned: pinned,
//      flexibleSpace: flexibleSpace
//  );
//}