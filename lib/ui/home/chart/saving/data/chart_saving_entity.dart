class SavingEntity {
  final double monthlySaving;
  final double _fraction;

  SavingEntity(this.monthlySaving, this._fraction);

  get fraction => _fraction == null || _fraction < 0 ? 0.0 : _fraction;
}