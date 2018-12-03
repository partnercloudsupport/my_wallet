import 'package:my_wallet/database/data.dart';
class ExpeneseEntity {
  final String name;
  final double amount;
  final TransactionType type;
  final String colorHex;

  ExpeneseEntity(this.name, this.amount, this.type, this.colorHex);
}