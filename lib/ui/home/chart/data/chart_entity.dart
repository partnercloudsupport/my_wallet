class ChartEntity {
  final List<TransactionEntity> income;
  final List<TransactionEntity> expense;

  ChartEntity(this.income, this.expense);
}

class TransactionEntity {
  final DateTime month;
  final double amount;

  TransactionEntity(this.month, this.amount);
}

