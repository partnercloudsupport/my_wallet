// #############################################################################################################################
// classes to be used in database
// #############################################################################################################################
enum AccountType {
  Saving,
  Cash,
  Credit,
  Loan,
  Assets
}

enum TransactionType {
  Income,
  Expenses
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

  AppTransaction(
      this.id,
      this.dateTime,
      this.accountId,
      this.categoryId,
      this.amount,
      this.desc,
      this.type
      );
}

class AppCategory {
  final int id;
  final String name;
  final TransactionType transactionType;
  final String colorHex;
  final double balance;

  const AppCategory(
      this.id,
      this.name,
      this.transactionType,
      this.colorHex,
      this.balance
      );
}

class Budget {
  final int id;
  final int categoryId;
  final double budgetPerMonth;
  final int budgetStart;
  final int budgetEnd;

  const Budget(
      this.id,
      this.categoryId,
      this.budgetPerMonth,
      this.budgetStart,
      this.budgetEnd
      );
}