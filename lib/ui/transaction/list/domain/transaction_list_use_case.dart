import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/transaction/list/data/transaction_list_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class TransactionListUseCase extends CleanArchitectureUseCase<TransactionListRepository>{
  TransactionListUseCase() : super(TransactionListRepository());

  void loadDataFor(
      int accountId,
      int categoryId,
      DateTime day,
      onNext<List<AppTransaction>> next
      ) {
    repo.loadDataFor(accountId, categoryId, day).then((value) => next(value));
  }
}