import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_repository.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';

class AddTransactionUseCase extends CleanArchitectureUseCase<AddTransactionRepository> {
  AddTransactionUseCase() : super(AddTransactionRepository());

  void loadAccounts(onNext<List<Account>> next) {
    repo.loadAccounts().then((value) => next(value));
  }

  void loadCategory(onNext<List<AppCategory>> next) {
    repo.loadCategory().then((value) => next(value));
  }

  void loadTransactionDetail(int id, onNext<TransactionDetail> next, onError error) {
    repo.loadTransactionDetail(id).then((value) => next(value)).catchError((e) => error(e));
  }

  void loadCurrentUserName(onNext<UserDetail> next) {
    repo.loadCurrentUserName().then((value) => next(value));
  }

  void saveTransaction(int _id,TransactionType _type, Account _account, AppCategory _category, double _amount, DateTime _date, onNext<bool> next, onError error) async {
    var result = false;
    try {
      do {
        if (!(await repo.checkTransactionType(_type))) break;
        if (!(await repo.checkAccount(_account))) break;
        if (!(await repo.checkCategory(_category))) break;
        if (!(await repo.checkDateTime(_date))) break;

        int id;
        TransactionDetail currentTransaction;
        if (_id == null) {
          id = await repo.generateId();
        } else {
          id = _id;
          currentTransaction = await repo.loadTransactionDetail(_id);
        }

        if (_amount == 0 && currentTransaction != null) {
          result = await repo.deleteTransaction(id);
        } else {
          result = await repo.saveTransaction(
              id,
              _type,
              _account,
              _category,
              _amount,
              _date,
              _category.name,
              _id == null);
        }

        if (!result) break;

        result = await repo.updateAccount(currentTransaction, _account, _type, _amount);

        next(result);
      } while(false);
    } catch (e) {
      error(e);
    }
  }
}