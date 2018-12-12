import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/home/home_view.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';

import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';

import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_view.dart';

import 'package:my_wallet/ui/category/list/presentation/view/list_category.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_view.dart';

import 'package:my_wallet/data/firebase_manager.dart' as fm;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:my_wallet/ui/user/login/presentation/view/login_view.dart';

import 'package:my_wallet/ui/user/detail/presentation/view/detail_view.dart';
import 'package:flutter/services.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);

  await fm.init();

  var sharedPref = await SharedPreferences.getInstance();

  var user = sharedPref.getString(UserUUID);

  print("dark blue ${AppTheme.darkBlue.value}");

  runApp(MyApp(user != null && user.isNotEmpty));
}


class MyApp extends StatelessWidget {

  final bool hasUser;
  MyApp(this.hasUser) : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wallet',
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
            case routes.UserProfile:
              return UserDetail();
            case routes.Login:
              return Login();
            default:
              return PlainScaffold(
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
