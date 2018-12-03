import 'package:flutter/material.dart';

import 'package:my_wallet/app_theme.dart' as theme;

import 'package:my_wallet/ui/home/home_view.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/routes.dart' as routes;
import 'package:my_wallet/database/data.dart';

import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';

import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_view.dart';

import 'package:my_wallet/ui/category/list/presentation/view/list_category.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_view.dart';

import 'package:my_wallet/database/firebase_manager.dart' as fm;

void main() => runApp(MyApp());


class MyApp extends StatefulWidget {

  MyApp() : super();

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    fm.init();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.appTheme,
      home: MyWalletHome(),
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
            case routes.SelectCategoryExpenses:
              return CategoryList("Select Category", TransactionType.Expenses);
            case routes.SelectCategoryIncome:
              return CategoryList("Select Category", TransactionType.Income);
            case routes.ListCategories:
              return CategoryList("Categories", null);
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
