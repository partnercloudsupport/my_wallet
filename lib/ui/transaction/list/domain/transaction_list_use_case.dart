import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/transaction/list/data/transaction_list_repository.dart';

class TransactionListUseCase {
  final TransactionListRepository _repo = TransactionListRepository();

  Future<List<AppTransaction>> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) {
    return _repo.loadDataFor(accountId, categoryId, day);
  }
}