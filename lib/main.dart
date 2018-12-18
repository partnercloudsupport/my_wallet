import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/home/home_view.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';

import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_view.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_view.dart';

import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_view.dart';

import 'package:my_wallet/ui/category/list/presentation/view/list_category.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_view.dart';

import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/data/firebase/authentication.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:my_wallet/ui/user/login/presentation/view/login_view.dart';
import 'package:my_wallet/ui/user/register/presentation/view/register_view.dart';
import 'package:my_wallet/ui/user/homeprofile/main/presentation/view/homeprofile_view.dart';

import 'package:my_wallet/ui/user/detail/presentation/view/detail_view.dart';
import 'package:my_wallet/ui/budget/list/presentation/view/list_view.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_view.dart';

import 'package:flutter/services.dart';

import 'package:my_wallet/firebase_config.dart' as fbConfig;
import 'package:firebase_core/firebase_core.dart';

import 'dart:io' show Platform;

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);

  FirebaseApp _app = await FirebaseApp.configure(
      name: Platform.isIOS ? "MyWallet" : "My Wallet",
      options: Platform.isIOS
          ? const FirebaseOptions(
        googleAppID: fbConfig.firebase_ios_app_id,
        gcmSenderID: fbConfig.firebase_gcm_sender_id,
        projectID: fbConfig.firebase_project_id,
        databaseURL: fbConfig.firebase_database_url,
      )
          : const FirebaseOptions(
        googleAppID: fbConfig.firebase_android_app_id,
        apiKey: fbConfig.firebase_api_key,
        projectID: fbConfig.firebase_project_id,
        databaseURL: fbConfig.firebase_database_url,
      ));

  await auth.init(_app);

  var sharedPref = await SharedPreferences.getInstance();

  var user = sharedPref.getString(UserUUID);
  var profile = sharedPref.getString(prefHomeProfile);

  await fdb.init(_app, homeProfile: profile);

  runApp(MyApp(user != null && user.isNotEmpty, profile != null && profile.isNotEmpty));
}

class _MaterialPageRoute<T> extends MaterialPageRoute<T> {
  _MaterialPageRoute({@required WidgetBuilder builder}) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {

  final bool hasUser;
  final bool hasProfile;

  MyApp(this.hasUser, this.hasProfile) : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wallet',
      theme: AppTheme.appTheme,
      home: hasUser && hasProfile ? MyWalletHome() : hasUser && !hasProfile ? HomeProfile() : Login(),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      onGenerateRoute: (settings) {
        return _MaterialPageRoute(builder: (context) {
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
            case routes.MyHome:
              return MyWalletHome();
            case routes.Register:
              return Register();
            case routes.HomeProfile:
              return HomeProfile();
            case routes.ListBudgets:
              return ListBudgets();
            case routes.AddBudget:
              return BudgetDetail("Create budget");
            default:
              Widget paramRoute = _getParamRoute(settings.name);

              if (paramRoute == null) {
                return PlainScaffold(
                  appBar: MyWalletAppBar(
                    title: "Coming Soon",
                  ),
                  body: Center(
                    child: Text("Unknown page ${settings.name}"),
                  ),
                );
              }

              return paramRoute;
              break;
          }
        });
      },
    );
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

    return null;
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler({this.resumeCallBack, this.suspendingCallBack});

  final Future<void> resumeCallBack;
  final Future<void> suspendingCallBack;

//  @override
//  Future<bool> didPopRoute()

//  @override
//  void didHaveMemoryPressure()

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
//        fm.dispose();
        break;
      case AppLifecycleState.resumed:
//        fm.resume();
        break;
    }
  }

//  @override
//  void didChangeLocale(Locale locale)

//  @override
//  void didChangeTextScaleFactor()

//  @override
//  void didChangeMetrics();

//  @override
//  Future<bool> didPushRoute(String route)
}
