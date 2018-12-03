import 'package:my_wallet/ui/transaction/add/data/add_transaction_repository.dart';
import 'package:my_wallet/database/data.dart';

class AddTransactionUseCase {
  final AddTransactionRepository _repo = AddTransactionRepository();

  Future<bool> saveTransaction(TransactionType _type, Account _account, AppCategory _category, double _amount, DateTime _date, String _desc) async {
    var result = false;
    do {
      if (!(await _repo.checkTransactionType(_type))) break;
      if (!(await _repo.checkAccount(_account))) break;
      if (!(await _repo.checkCategory(_category))) break;
      if (!(await _repo.checkDateTime(_date))) break;
      if (!(await _repo.checkDescription(_desc))) break;

      int id = await _repo.generateId();

      result = await _repo.saveTransaction(id, _type, _account, _category, _amount, _date, _desc);
      
      if (!result) break;

      result = await _repo.updateAccount(_account, _type, _amount);
    } while (false);

    return result;
  }
}
