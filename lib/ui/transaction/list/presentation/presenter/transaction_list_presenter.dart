import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/ui/transaction/list/domain/transaction_list_use_case.dart';

class TransactionListPresenter {
  final TransactionListUseCase _useCase = TransactionListUseCase();

  Future<List<AppTransaction>> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) {
    return _useCase.loadDataFor(accountId, categoryId, day);
  }
}