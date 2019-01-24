import 'package:my_wallet/ui/account/list/data/list_accounts_repository.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class ListAccountsUseCase extends CleanArchitectureUseCase<ListAccountsRepository>{
  ListAccountsUseCase() : super(ListAccountsRepository());

  void loadAllAccounts(onNext<List<Account>> next) {
    execute<List<Account>>(repo.loadAllAccounts(), next, (e) {
      debugPrint("onLoadAccount error $e");
      next([]);
    });
  }

  void deleteAccount(Account acc, onNext<bool> next) {
    execute<bool>(Future(() async {
      if(acc != null && acc.id != null) {
        await repo.deleteAccount(acc).then((result) => next(result));

        List<AppTransaction> transactions = await repo.loadAllTransaction(acc.id);

        if (transactions != null && transactions.isNotEmpty) {
          await repo.deleteAllTransaction(transactions);
        }

        List<Transfer> transfer = await repo.loadAllTransfers(acc.id);

        if(transfer !=null && transfer.isNotEmpty) {
          await repo.deleteAllTransfer(transfer);
        }
      }
    }), next, (e) {
      debugPrint("Delete account error");
      next(false);
    });
  }
}