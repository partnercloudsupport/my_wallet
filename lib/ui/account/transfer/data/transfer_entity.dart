import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

class TransferEntity {
  final Account fromAccount;
  final List<Account> toAccounts;

  TransferEntity(this.fromAccount, this.toAccounts);
}