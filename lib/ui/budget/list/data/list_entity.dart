class BudgetEntity {
  final int categoryId;
  final String categoryName;
  final double total;
  final double spent;

  BudgetEntity(this.categoryId, this.categoryName, this.spent, this.total);
}