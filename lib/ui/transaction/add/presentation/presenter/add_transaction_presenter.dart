import 'package:my_wallet/ui/transaction/add/domain/add_transaction_use_case.dart';
import 'package:my_wallet/database/data.dart';

class AddTransactionPresenter {
  final AddTransactionUseCase _useCase = AddTransactionUseCase();

  Future<bool> saveTransaction(
      TransactionType _type,
      Account _account,
      AppCategory _category,
      double _amount,
      DateTime _date,
      String _desc) {
    return _useCase.saveTransaction(
        _type,
        _account,
        _category,
        _amount,
        _date,
        _desc
    );
  }
}