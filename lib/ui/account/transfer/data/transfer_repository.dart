import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/account/transfer/data/transfer_entity.dart';
export 'package:my_wallet/ui/account/transfer/data/transfer_entity.dart';

import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/data/firebase/database.dart' as _fdb;

class AccountTransferRepository extends CleanArchitectureRepository {
  _AccountTransferDatabaseRepository _dbRepo = _AccountTransferDatabaseRepository();
  _AccountTransferFirebaseRepository _fbRepo = _AccountTransferFirebaseRepository();

  Future<TransferEntity> loadAccountDetails(int fromAccountId) {
    return _dbRepo.loadAccountDetails(fromAccountId);
  }

  Future<int> generateTransferId() {
    return _dbRepo.generateTransferId();
  }

  Future<bool> transferAmount(Transfer transfer) {
    _fbRepo.transferAmount(transfer);
    return _dbRepo.transferAmount(transfer);
  }
}

class _AccountTransferDatabaseRepository {
  Future<TransferEntity> loadAccountDetails(int fromAccountId) async {
    Account fromAccount;
    List<Account> toAccounts;

    do {
      // load From account info
      var fromAccounts = await _db.queryAccounts(id: fromAccountId);

      if(fromAccounts == null || fromAccounts.isEmpty) throw Exception("Account with ID $fromAccountId is invalid");

      fromAccount = fromAccounts.first;

      toAccounts = await _db.queryAccountsExcept([fromAccountId]);
    } while (false);

    return TransferEntity(fromAccount, toAccounts);
  }

  Future<int> generateTransferId() {
    return _db.generateTransferId();
  }

  Future<bool> transferAmount(Transfer transfer) async {
    return (await _db.insertTransfer(transfer)) > 0;
  }
}

class _AccountTransferFirebaseRepository {
  Future<bool> transferAmount(Transfer transfer) {
    return _fdb.addTransfer(transfer);
  }
}