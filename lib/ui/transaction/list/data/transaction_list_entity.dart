import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';
class TransactionEntity {
  final int id;
  final String userInitial;
  final String categoryName;
  final String transactionDesc;
  final double amount;
  final DateTime dateTime;
  final int userColor;
  final int transactionColor;
  final bool isTransfer;

  TransactionEntity(
      this.id,
      this.userInitial,
      this.categoryName,
      this.transactionDesc,
      this.amount,
      this.dateTime,
      this.userColor,
      this.transactionColor,
      this.isTransfer,
      );
}

class TransactionListEntity {
  final List<TransactionEntity> entities;
  final List<DateTime> dates;
  final double total;
  final double fraction;

  TransactionListEntity(this.entities, this.dates, this.total, this.fraction);
}