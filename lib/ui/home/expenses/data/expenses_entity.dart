import 'package:my_wallet/database/data.dart';
class ExpeneseEntity {
  final int categoryId;
  final String name;
  final double amount;
  final String colorHex;

  ExpeneseEntity(this.categoryId, this.name, this.amount, this.colorHex);
}