import 'package:my_wallet/ui/account/list/data/list_accounts_repository.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class ListAccountsUseCase extends CleanArchitectureUseCase<ListAccountsRepository>{
  ListAccountsUseCase() : super(ListAccountsRepository());

  void loadAllAccounts(onNext<List<Account>> next) {
    execute<List<Account>>(repo.loadAllAccounts(), next, (e) {
      print("onLoadAccount error $e");
      next([]);
    });
  }

  void deleteAccount(Account acc, onNext<bool> next) {
    execute<bool>(Future(() async {
      if(acc != null && acc.id != null) {
        await repo.deleteAccount(acc).then((result) => next(result));

        List<AppTransaction> transactions = await repo.loadAllTransaction(acc.id);

        if (transactions != null && transactions.isNotEmpty) {
          for (int i = 0; i < transactions.length; i++) {
            await repo.deleteTransaction(transactions[i]);
          }
        }
      }
    }), next, (e) {
      print("Delete account error");
      next(false);
    });
  }
}