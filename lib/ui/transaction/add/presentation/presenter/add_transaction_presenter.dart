import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/domain/add_transaction_use_case.dart';
import 'package:my_wallet/data/data.dart';

class AddTransactionPresenter extends CleanArchitecturePresenter<AddTransactionUseCase, AddTransactionDataView> {
  AddTransactionPresenter() : super(AddTransactionUseCase());

  void loadAccounts() {
    useCase.loadAccounts(dataView.onAccountListLoaded);
  }

  void loadCategory(TransactionType _type) {
    useCase.loadCategory(_type, dataView.onCategoryListLoaded);
  }

  void loadTransactionDetail(int id) {
    useCase.loadTransactionDetail(id, dataView.onLoadTransactionDetail, dataView.onLoadTransactionFailed);
  }

  void loadPresetDetail(int accountId, int categoryId) {
    useCase.loadPresetDetail(accountId, categoryId, dataView.onLoadTransactionDetail, dataView.onLoadTransactionFailed);
  }

  void loadCurrentUserName() {
    useCase.loadCurrentUserName(dataView.updateUserDisplayName);
  }

  void saveTransaction(
      int id,
      TransactionType _type,
      Account _account,
      AppCategory _category,
      double _amount,
      DateTime _date,
      String _desc) {
    print("_account $_account _category $_category");
    useCase.saveTransaction(
      id,
        _type,
        _account,
        _category,
        _amount,
        _date,
        _desc,
      dataView.onSaveTransactionSuccess,
      dataView.onSaveTransactionFailed
    );
  }
}