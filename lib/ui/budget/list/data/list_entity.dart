import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';
class BudgetEntity {
  final int categoryId;
  final String categoryName;
  final double total;
  final double transaction;
  final String colorHex;
  final CategoryType type;

  BudgetEntity(this.categoryId, this.categoryName, this.colorHex, this.transaction, this.total, this.type);
}

class BudgetListEntity {
  final List<BudgetEntity> income;
  final List<BudgetEntity> expense;
  final double incomeBudget;
  final double expenseBudget;
  final double totalIncome;
  final double totalExpense;

  BudgetListEntity(this.income, this.expense, this.incomeBudget, this.expenseBudget, this.totalIncome, this.totalExpense);

  static BudgetListEntity empty() => BudgetListEntity([], [], 0.0, 0.0, 0.0, 0.0);
}

class BudgetSummary {
  final DateTime month;
  final double total;
  final double spent;

  BudgetSummary(this.month, this.total, this.spent);
}