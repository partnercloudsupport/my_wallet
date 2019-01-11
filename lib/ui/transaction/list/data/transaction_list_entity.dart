class TransactionEntity {
  final int id;
  final String userInitial;
  final String transactionDesc;
  final double amount;
  final DateTime dateTime;
  final int userColor;
  final int transactionColor;

  TransactionEntity(
      this.id,
      this.userInitial,
      this.transactionDesc,
      this.amount,
      this.dateTime,
      this.userColor,
      this.transactionColor
      );
}

class TransactionListEntity {
  final List<TransactionEntity> entities;
  final List<DateTime> dates;

  TransactionListEntity(this.entities, this.dates);
}