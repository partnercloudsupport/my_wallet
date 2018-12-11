import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ui/transaction/list/domain/transaction_list_use_case.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/transaction/list/presentation/view/transaction_list_data_view.dart';

class TransactionListPresenter extends CleanArchitecturePresenter<TransactionListUseCase, TransactionListDataView>{
  TransactionListPresenter() : super(TransactionListUseCase());

  void loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) {
    return useCase.loadDataFor(accountId, categoryId, day, dataView.onTransactionListLoaded);
  }
}