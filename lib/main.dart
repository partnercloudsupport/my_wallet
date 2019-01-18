import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/home/homemain/presentation/view/homemain_view.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';

import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';

import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_view.dart';
import 'package:my_wallet/ui/account/detail/presentation/view/detail_view.dart';

import 'package:my_wallet/ui/category/list/presentation/view/list_category.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_view.dart';

import 'package:my_wallet/ui/user/login/presentation/view/login_view.dart';
import 'package:my_wallet/ui/user/register/presentation/view/register_view.dart';
import 'package:my_wallet/ui/user/homeprofile/main/presentation/view/homeprofile_view.dart';
import 'package:my_wallet/ui/user/detail/presentation/view/detail_view.dart';

import 'package:my_wallet/ui/budget/list/presentation/view/list_view.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_view.dart';

import 'package:my_wallet/ui/about/presentation/view/about_view.dart';

import 'package:my_wallet/ui/splash/presentation/view/splash_view.dart';

import 'package:flutter/services.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  final GlobalKey<MyWalletState> homeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
      title: 'My Wallet',
      theme: AppTheme.appTheme,
      home: SplashView(), //hasUser && hasProfile ? MyWalletHome() : hasUser && !hasProfile ? HomeProfile() : Login(),
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
            case routes.MyHome:
              return MyWalletHome(key: homeKey,);
            case routes.Register:
              return Register();
            case routes.HomeProfile:
              return HomeProfile();
            case routes.ListBudgets:
              return ListBudgets();
            case routes.AboutUs:
              return AboutUs();
            case routes.SplashView:
              return SplashView();
            default:
              Widget paramRoute = _getParamRoute(settings.name);

              if (paramRoute == null) {
                return PlainScaffold(
                  appBar: MyWalletAppBar(
                    title: "Coming Soon",
                  ),
                  body: Center(
                    child: Text("Unknown page ${settings.name}", style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
                  ),
                );
              }

              return paramRoute;
              break;
          }
        });
      },
    );

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(app, homeKey));

    return app;
  }

  Widget _getParamRoute(String name) {
    if (name.startsWith(routes.AddTransaction)) {
      return AddTransaction(transactionId: int.parse(name.replaceFirst("${routes.AddTransaction}/", "")),);
    }

    if(name.startsWith(routes.TransactionListAccount)) {
      do {
        // get title:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String accountId = detail.replaceFirst("${routes.TransactionListAccount}/", "");

        if (accountId == null || accountId.isEmpty) break;

        try {
          int id = int.parse(accountId);
          return TransactionList(title, accountId: id,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.TransactionListCategory)) {
      do {
        // get title:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String categoryId = detail.replaceFirst("${routes.TransactionListCategory}/", "");

        if (categoryId == null || categoryId.isEmpty) break;

        try {
          int id = int.parse(categoryId);
          return TransactionList(title, categoryId: id,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.TransactionListDate)) {
      do {
        // get title:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String title = splits[1];
        String detail = splits[0];

        String date = detail.replaceFirst("${routes.TransactionListDate}/", "");

        if (date == null || date.isEmpty) break;

        try {
          int millisecondsSinceEpoch = int.parse(date);

          DateTime day = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

          return TransactionList(title, day: day,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.AddBudget)) {
      do {
        // get month date/time:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String date = splits[1];
        String title = splits[0];

        if (date == null || date.isEmpty) break;

        try {
          int millisecondsSinceEpoch = int.parse(date);

          DateTime day = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

          return BudgetDetail("Budget", categoryId: int.parse(title.replaceFirst("${routes.AddBudget}/", "")), month: day,);
        } catch(e) {}
      } while (false);
    }

    if(name.startsWith(routes.Accounts)) {
      do {
        String data = name.replaceFirst("${routes.Accounts}/", "");

        if(data == null) break;
        if(data.isEmpty) break;

        List<String> splits = data.split(":");

        String strAccId = splits[0];
        String accName = splits[1];

        try {
          int _accountId = int.parse(strAccId);
          return AccountDetail(_accountId, accName);
        } catch(e) {}
      } while(false);
    }

    return null;
  }

}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler(this.app, this.homeKey);

  final MaterialApp app;
  final GlobalKey<MyWalletState> homeKey;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        if(homeKey.currentContext != null) {
          homeKey.currentState.onPaused();
        }
        break;
      case AppLifecycleState.resumed:
        if(homeKey.currentContext != null) {
          homeKey.currentState.onResume();
        }
        break;
    }
  }
}
