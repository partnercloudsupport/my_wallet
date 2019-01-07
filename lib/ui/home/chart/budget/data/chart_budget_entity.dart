class ChartBudgetEntity {
  final double spent;
  final double budget;
  final double _fraction;

  ChartBudgetEntity(this.spent, this.budget, this._fraction);

  get fraction => _fraction == null || _fraction < 0 ? 0.0 : _fraction;
}