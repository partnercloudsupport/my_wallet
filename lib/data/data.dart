import 'package:my_wallet/utils.dart' as Utils;

// #############################################################################################################################
// classes to be used in database
// #############################################################################################################################
class AccountType {
  final String name;
  final int id;
  AccountType(this.id, this.name);

  static final List<AccountType> all =[
    paymentAccount,
    credit,
    assets,
    liability
  ];

  static final AccountType paymentAccount = AccountType(0, "Payment Account");
  static final AccountType credit = AccountType(1, "Credit");
  static final AccountType assets = AccountType(2, "Assets");
  static final AccountType liability = AccountType(3, "Liability");
}

class TransactionType {
  final String name;
  final int id;

  TransactionType(this.id, this.name);

  static final expenses = TransactionType(0, "Expense");
  static final income = TransactionType(1, "Income");
//  static final moneyTransfer = TransactionType(2, "Money Transfer");
//  static final assetPurchase = TransactionType(3, "Asset Purchase");
//  static final assetSale = TransactionType(4, "Asset Sale");
//  static final liabilityAcquisition = TransactionType(5, "Liability Acquisition");
//  static final dischargeOfLiability = TransactionType(6, "Discharge Of Liability");

  static final List<TransactionType> typeIncome = [
    income,
//    assetSale,
//    liabilityAcquisition
  ];

  static final List<TransactionType> typeExpense = [
    expenses,
//    assetPurchase,
//    dischargeOfLiability
  ];

  static final List<TransactionType> all = [
    expenses,
    income,
//    moneyTransfer,
//    assetSale,
//    assetSale,
//    liabilityAcquisition,
//    dischargeOfLiability
  ];

  static bool isExpense(TransactionType type) {
    return typeExpense.contains(type);
  }

  static bool isIncome(TransactionType type) {
    return typeIncome.contains(type);
  }
}

class Account {
  final int id;
  final String name;
  final double balance;
  final AccountType type;
  final String currency;

  Account(
      this.id,
      this.name,
      this.balance,
      this.type,
      this.currency
      );
}

class AppTransaction {
  final int id;
  final DateTime dateTime;
  final int accountId;
  final int categoryId;
  final double amount;
  final String desc;
  final TransactionType type;
  final String userUid;

  AppTransaction(
      this.id,
      this.dateTime,
      this.accountId,
      this.categoryId,
      this.amount,
      this.desc,
      this.type,
      this.userUid
      );
}

class AppCategory {
  final int id;
  final String name;
  final String colorHex;
  final double income;
  final double expense;

  const AppCategory(
      this.id,
      this.name,
      this.colorHex,
      this.income,
      this.expense
      );
}

class Budget {
  final int id;
  final int categoryId;
  final double budgetPerMonth;
  final DateTime _start;
  final DateTime _end;
  double spent;
  double earn;

  Budget(
      this.id,
      this.categoryId,
      this.budgetPerMonth,
      this._start,
      this._end,
      {this.spent, this.earn}
      );

  DateTime get budgetStart => Utils.firstMomentOfMonth(_start);
  DateTime get budgetEnd => Utils.lastDayOfMonth(_end);
}

class User {
  final String uuid;
  final String email;
  final String displayName;
  final String photoUrl;
  final int color;

  User(this.uuid, this.email, this.displayName, this.photoUrl, this.color);

  @override
  String toString() {
    return "$email - $displayName - $color";
  }
}

class Home {
  final String host;
  final String key;
  final String name;

  Home(this.key, this.host, this.name);

  @override
  String toString() {
    return "$key - $host - $name";
  }
}