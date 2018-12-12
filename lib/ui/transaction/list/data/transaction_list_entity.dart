class TransactionEntity {
  final int id;
  final String userInitial;
  final String transactionDesc;
  final double amount;
  final DateTime dateTime;

  TransactionEntity(
      this.id,
      this.userInitial,
      this.transactionDesc,
      this.amount,
      this.dateTime
      );
}