import 'package:flutter/material.dart';

import 'package:my_wallet/ui/home/home_view.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';

import 'package:my_wallet/app_material.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';

import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_view.dart';

import 'package:my_wallet/ui/category/list/presentation/view/list_category.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_view.dart';

import 'package:my_wallet/data/firebase_manager.dart' as fm;
import 'package:my_wallet/ui/user/login/presentation/view/login_view.dart';

void main() async {
  await fm.init();

  var user = await fm.checkCurrentUser();
  runApp(MyApp(user));
}


class MyApp extends StatelessWidget {

  final bool hasUser;
  MyApp(this.hasUser) : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.appTheme,
      home: hasUser ? MyWalletHome() : Login(),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          switch (settings.name) {
            case routes.AddTransaction:
              return AddTransaction();
              break;
            case routes.AddAccount:
              return CreateAccount();
              break;
            case routes.SelectAccount:
              return ListAccounts(
                "SelectAccount",
                selectionMode: true,
              );
              break;
            case routes.ListAccounts:
              return ListAccounts("Accounts");
              break;
            case routes.SelectCategory:
              return CategoryList("Select Category", returnValue: true,);
            case routes.ListCategories:
              return CategoryList("Categories");
            case routes.CreateCategory:
              return CreateCategory();
            default:
              return Scaffold(
                appBar: MyWalletAppBar(
                  title: "Coming Soon",
                ),
                body: Center(
                  child: Text("Unknown page ${settings.name}"),
                ),
              );
              break;
          }
        });
      },
    );
  }
}
