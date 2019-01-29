export 'package:my_wallet/data/data.dart';

class ExpenseEntity {
  final int categoryId;
  final String name;
  final String colorHex;
  final double transaction;
  final double remain;
  final double budget;
  final double remainFactor;

  ExpenseEntity(this.categoryId, this.name, this.colorHex, this.transaction, this.remain, this.budget, this.remainFactor);
}