import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

class TransactionDetail {
  final int id;
  final DateTime dateTime;
  final Account account;
  final AppCategory category;
  final double amount;
  final TransactionType type;
  final UserDetail user;

  TransactionDetail(this.id, this.dateTime, this.account, this.category, this.amount, this.type, this.user);

}

class UserDetail {
  final String uid;
  final String fistName;

  UserDetail(this.uid, this.fistName);
}