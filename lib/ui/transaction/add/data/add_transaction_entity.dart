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
  final String desc;

  TransactionDetail(this.id, this.dateTime, this.account, this.category, this.amount, this.type, this.user, this.desc);

  static TransactionDetail preset({int id, DateTime dateTime, Account account, AppCategory category, double amount, TransactionType type, UserDetail userDetail, String desc }) {
    return TransactionDetail(id, dateTime ?? DateTime.now(), account, category, amount ?? 0.0, type ?? TransactionType.expenses, userDetail, desc);
  }
}

class UserDetail {
  final String uid;
  final String firstName;

  UserDetail(this.uid, this.firstName);
}