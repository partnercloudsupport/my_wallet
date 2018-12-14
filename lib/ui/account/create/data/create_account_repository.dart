import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/ui/account/create/domain/create_account_exception.dart';
import 'package:my_wallet/data/firebase/database.dart' as fm;
import 'package:my_wallet/ca/data/ca_repository.dart';

class CreateAccountRepository extends CleanArchitectureRepository {
  final _CreateAccountDatabaseRepository _dbRepo = _CreateAccountDatabaseRepository();
  final _CreateAccountFirebaseRepository _fbRepo = _CreateAccountFirebaseRepository();

  Future<int> generateAccountId() {
    return _dbRepo.generateAccountId();
  }

  Future<bool> saveAccountToFirebase(
      int id,
      String name,
      double balance,
      AccountType type
      ) {
    return _fbRepo.createAccountToFirebase(Account(id, name, balance, type, "\$"));
  }

  Future<bool> verifyType(AccountType type) {
    return _dbRepo.verifyType(type);
  }

  Future<bool> verifyName(String name) {
    return _dbRepo.verifyName(name);
  }
}

class _CreateAccountDatabaseRepository {
  Future<int> generateAccountId() async {
    return await db.generateAccountId();
  }

  Future<bool> verifyType(AccountType type) async {
    return type == null ? throw CreateAccountException("Please select account type") : true;
  }

  Future<bool> verifyName(String name) async {
    return name == null || name.isEmpty ? throw CreateAccountException("Please enter account name") : true;
  }
}

class _CreateAccountFirebaseRepository {
  Future<bool> createAccountToFirebase(Account acc) async {
     return await fm.addAccount(acc);

  }
}