export 'package:my_wallet/data/data.dart';

class ExpenseEntity {
  final int categoryId;
  final String name;
  final double income;
  final double expense;
  final String colorHex;
  final double remainFactor;
  final double budget;

  ExpenseEntity(this.categoryId, this.name, this.income, this.expense, this.colorHex, this.remainFactor, this.budget);
}