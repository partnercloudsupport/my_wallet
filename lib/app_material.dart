export 'package:my_wallet/style/app_theme.dart';
export 'package:my_wallet/style/routes.dart';
export 'package:my_wallet/widget/bottom_sheet_list.dart';
export 'package:my_wallet/widget/conversation_row.dart';
export 'package:my_wallet/widget/my_wallet_app_bar.dart';
export 'package:my_wallet/widget/number_input_pad.dart';
export 'package:my_wallet/widget/select_transaction_type.dart';

import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';

class GradientScaffold extends Scaffold {
  GradientScaffold({
    Key key,
    MyWalletAppBar appBar,
    Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<Widget> persistentFooterButtons,
    Widget drawer,
    Widget endDrawer,
    Widget bottomNavigationBar,
    Widget bottomSheet,
    bool resizeToAvoidBottomPadding = true,
    bool primary = true,
  }) : super(
            key: key,
            appBar: appBar,
            body: Container(
              decoration: BoxDecoration(gradient: AppTheme.bgGradient),
              child: body,
            ),
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            floatingActionButtonAnimator: floatingActionButtonAnimator,
            persistentFooterButtons: persistentFooterButtons,
            drawer: drawer,
            endDrawer: endDrawer,
            bottomNavigationBar: bottomNavigationBar,
            bottomSheet: bottomSheet,
            resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
            primary: primary);
}

class PlainScaffold extends Scaffold {
  PlainScaffold({
    Key key,
    MyWalletAppBar appBar,
    Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<Widget> persistentFooterButtons,
    Widget drawer,
    Widget endDrawer,
    Widget bottomNavigationBar,
    Widget bottomSheet,
    bool resizeToAvoidBottomPadding = true,
    bool primary = true,
  }) : super(
      key: key,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
      primary: primary);
}