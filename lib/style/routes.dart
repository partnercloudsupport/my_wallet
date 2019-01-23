import 'package:flutter/foundation.dart';

class routes {
  static const AddTransaction = "AddTransaction";
  static const TransactionListAccount = "TransactionListAccount";
  static const TransactionListCategory = "TransactionListCategory";
  static const TransactionListDate = "TransactionListDate";

  static const SelectCategory = "SelectCategory";
  static const ListCategories = "ListCategories";
  static const CreateCategory = "CreateCategory";

  static const SelectAccount = "SelectAccountEx";
  static const ListAccounts = "ListAccounts";
  static const Accounts = "_AccountDetail";
  static const AddAccount = "AddAccount";
  static const TransferAccount = "TransferAccount";

  static const UserProfile = "UserProfile";

  static const Login = "Login";
  static const HomeProfile = "HomeProfile";
  static const MyHome = "MyHome";
  static const Register = "Register";

  static const ListBudgets = "ListBudgets";
  static const AddBudget = "AddBudget";

  static const AboutUs = "AboutUs";

  static const SplashView = "SplashView";
  static const Liability = "Liability";
  static const Pay = "PayLiability";

  static String EditTransaction(int id) {
    return "$AddTransaction/$id";
  }

  static String TransactionList(String title, {int accountId, int categoryId, DateTime datetime}) {
    if(accountId != null) return "$TransactionListAccount/$accountId:$title";
    if(categoryId != null) return "$TransactionListCategory/$categoryId:$title";
    if(datetime != null) return "$TransactionListDate/${datetime.millisecondsSinceEpoch}:$title";

    return "Unknown";
  }

  static String EditBudget({@required int categoryId, @required DateTime month}) {
    return "$AddBudget/$categoryId:${month.millisecondsSinceEpoch}";
  }

  static String AccountDetail({@required int accountId, @required String accountName}) {
    return "$Accounts/$accountId:$accountName";
  }

  static String TransferToAccount({@required String accountName, @required int accountId}) {
    return "$TransferAccount/from:$accountId/name:$accountName";
  }

  static String LiabilityDetail({@required int accountId, @required String accountName}) {
    return "$Liability/from:$accountId/name:$accountName";
  }

  static String PayLiability({@required int accountId, @required String accountName}) {
    return "$Pay/from:$accountId/name:$accountName";
  }
}