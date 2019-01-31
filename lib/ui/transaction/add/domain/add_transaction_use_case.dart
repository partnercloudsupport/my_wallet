import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_repository.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';

class AddTransactionUseCase extends CleanArchitectureUseCase<AddTransactionRepository> {
  AddTransactionUseCase() : super(AddTransactionRepository());

  void loadAccounts(onNext<List<Account>> next) {
    execute(repo.loadAccounts(), next, (e) {
      debugPrint("Load accounts error $e");
      next([]);
    });
  }

  void loadCategory(TransactionType _type, onNext<List<AppCategory>> next) {
    execute(Future(() {
      var categoryType = CategoryType.expense;
      if(TransactionType.isIncome(_type)) categoryType = CategoryType.income;

      return repo.loadCategories(categoryType);
    }), next, (e) {
      debugPrint("Load category error $e");
      next([]);
    });
  }

  void loadTransactionDetail(int id, onNext<TransactionDetail> next, onError error) {
    execute(repo.loadTransactionDetail(id), next, error);
  }
  
  void loadPresetDetail(int accountId, int categoryId, onNext<TransactionDetail> next, onError error) {
    execute(Future(() async {
      // load user detail
      UserDetail userDetail = await repo.loadCurrentUserName();
      
      // load account
      Account account;
      if(accountId != null) {
        account = await repo.loadAccount(accountId);
      } else {
        // load last used account for category
        account = await repo.loadLastUsedAccountForCategory(categoryId);
      }
      
      // load category
      AppCategory category;
      if(categoryId != null) {
        category = await repo.loadCategory(categoryId);
      }

      return TransactionDetail.preset(account: account, category: category, userDetail: userDetail);
    }), next, error);
  }

  void loadCurrentUserName(onNext<UserDetail> next) {
    execute(repo.loadCurrentUserName(), next, (e) {});
  }

  void saveTransaction(int _id,TransactionType _type, Account _account, AppCategory _category, double _amount, DateTime _date, String _desc, onNext<bool> next, onError error) async {
    execute(Future(() async {
      var result = false;

      do {
        if (!(await repo.checkTransactionType(_type))) break;
        if (!(await repo.checkAccount(_account))) break;
        if (!(await repo.checkCategory(_category))) break;
        if (!(await repo.checkDateTime(_date))) break;

        if(_amount == 0 && _id == null) {
          throw Exception("Please enter your transaction amount");
        }

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
              _desc,
              _id == null);
        }

        if(result) {
          //
        }
        result = true;
      } while(false);

      return result;
    }), next, error);
  }
}