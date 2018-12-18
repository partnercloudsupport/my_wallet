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
  static const AddAccount = "AddAccount";

  static const UserProfile = "UserProfile";

  static const Login = "Login";
  static const HomeProfile = "HomeProfile";
  static const MyHome = "MyHome";
  static const Register = "Register";

  static const ListBudgets = "ListBudgets";
  static const AddBudget = "AddBudget";

  static String EditTransaction(int id) {
    return "$AddTransaction/$id";
  }

  static String TransactionList(String title, {int accountId, int categoryId, DateTime datetime}) {
    if(accountId != null) return "$TransactionListAccount/$accountId:$title";
    if(categoryId != null) return "$TransactionListCategory/$categoryId:$title";
    if(datetime != null) return "$TransactionListDate/${datetime.millisecondsSinceEpoch}:$title";

    return "Unknown";
  }

  static String EditBudget({@required int categoryId}) {
    return "$AddBudget/$categoryId";
  }
}