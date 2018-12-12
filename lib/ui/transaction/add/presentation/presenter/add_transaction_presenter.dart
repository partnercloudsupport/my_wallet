import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/domain/add_transaction_use_case.dart';
import 'package:my_wallet/data/data.dart';

class AddTransactionPresenter extends CleanArchitecturePresenter<AddTransactionUseCase, AddTransactionDataView> {
  AddTransactionPresenter() : super(AddTransactionUseCase());

  void loadAccounts() {
    useCase.loadAccounts(dataView.onAccountListLoaded);
  }

  void loadCategory() {
    useCase.loadCategory(dataView.onCategoryListLoaded);
  }

  void loadTransactionDetail(int id) {
    useCase.loadTransactionDetail(id, dataView.onLoadTransactionDetail, dataView.onLoadTransactionFailed);
  }

  void loadCurrentUserName() {
    useCase.loadCurrentUserName(dataView.onUserDetailLoaded);
  }

  void saveTransaction(
      int id,
      TransactionType _type,
      Account _account,
      AppCategory _category,
      double _amount,
      DateTime _date) {
    useCase.saveTransaction(
      id,
        _type,
        _account,
        _category,
        _amount,
        _date,
      dataView.onSaveTransactionSuccess,
      dataView.onSaveTransactionFailed
    );
  }
}