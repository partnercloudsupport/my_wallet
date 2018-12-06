export 'package:my_wallet/database/data.dart';
class TransactionEntity {
  final String category;
  final double amount;
  final String color;

  TransactionEntity(this.category, this.amount, this.color);
}