import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

class BudgetDetailEntity {
  final DateTime from;
  final DateTime to;
  final AppCategory category;
  final double amount;

  BudgetDetailEntity(this.category, this.amount, this.from, this.to);
}