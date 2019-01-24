import 'package:my_wallet/utils.dart' as Utils;

// #############################################################################################################################
// classes to be used in database
// #############################################################################################################################
class AccountType {
  final String name;
  final int id;
  AccountType._(this.id, this.name);

  static final List<AccountType> all =[
    paymentAccount,
    credit,
    assets,
    liability
  ];

  static final AccountType paymentAccount = AccountType._(0, "Payment Account");
  static final AccountType credit = AccountType._(1, "Credit");
  static final AccountType assets = AccountType._(2, "Assets");
  static final AccountType liability = AccountType._(3, "Liability");
}

class TransactionType {
  final String name;
  final int id;

  TransactionType._(this.id, this.name);

  static final expenses = TransactionType._(0, "Expense");
  static final income = TransactionType._(1, "Income");
  static final moneyTransfer = TransactionType._(2, "Money Transfer");
//  static final assetPurchase = TransactionType._(3, "Asset Purchase");
//  static final assetSale = TransactionType._(4, "Asset Sale");
//  static final liabilityAcquisition = TransactionType._(5, "Liability Acquisition");
  static final dischargeOfLiability = TransactionType._(6, "Discharge Of Liability");

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
    moneyTransfer,
//    assetSale,
//    assetSale,
//    liabilityAcquisition,
//    dischargeOfLiability
  ];

  static final List<TransactionType> dailyTransaction = []
    ..addAll(typeExpense)
    ..addAll(typeIncome);

  static bool isExpense(TransactionType type) {
    return typeExpense.contains(type);
  }

  static bool isIncome(TransactionType type) {
    return typeIncome.contains(type);
  }
}

class CategoryType {
  final int id;
  final String name;
  CategoryType._(this.id, this.name);

  static final expense = CategoryType._(0, "Expense");
  static final income = CategoryType._(1, "Income");

  static List<CategoryType> all = [
    expense,
    income
  ];
}

class Account {
  final int id;
  final String name;
  final double initialBalance;
  final DateTime created;
  final AccountType type;
  final String currency;
  // internal use
  double balance;
  double spent;
  double earn;

  Account(
      this.id,
      this.name,
      this.initialBalance,
      this.type,
      this.currency,
  {
    this.created,
    this.balance,
    this.spent,
    this.earn
  }
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

class DischargeOfLiability extends AppTransaction {
  final int liabilityId;

  DischargeOfLiability(
      int id,
      DateTime dateTime,
      this.liabilityId,
      int accountId,
      int categoryId,
      double amount,
      String userUid) : super(id, dateTime, accountId, categoryId, amount, "Discharge Of Liability", TransactionType.dischargeOfLiability, userUid);
}

class AppCategory {
  final int id;
  final String name;
  final String colorHex;
  final CategoryType categoryType;
  double income;
  double expense;

  AppCategory(
      this.id,
      this.name,
      this.colorHex,
      this.categoryType,
      {
        this.income = 0.0,
        this.expense = 0.0}
      );
}

class Budget {
  final int id;
  final int categoryId;
  final double budgetPerMonth;
  final DateTime _start;
  final DateTime _end;

  Budget(
      this.id,
      this.categoryId,
      this.budgetPerMonth,
      this._start,
      this._end,
      );

  DateTime get budgetStart => _start == null ? null : Utils.firstMomentOfMonth(_start);
  DateTime get budgetEnd => _end == null ? null : Utils.lastDayOfMonth(_end);

  @override
  String toString() {
    return "Budget $id for category $categoryId amount $budgetPerMonth from $budgetStart until $budgetEnd";
  }
}

class User {
  final String uuid;
  final String email;
  final String displayName;
  final String photoUrl;
  final int color;
  final bool isVerified;

  User(this.uuid, this.email, this.displayName, this.photoUrl, this.color, this.isVerified);

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

class Transfer {
  final int id;
  final int fromAccount;
  final int toAccount;
  final double amount;
  final DateTime transferDate;
  final String userUuid;

  Transfer(this.id, this.fromAccount, this.toAccount, this.amount, this.transferDate, this.userUuid);
}