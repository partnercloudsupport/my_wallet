import 'package:my_wallet/ui/home/chart/transactions/domain/transaction_use_case.dart';
import 'package:my_wallet/ui/home/chart/transactions/data/transaction_entity.dart';
import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:my_wallet/ui/home/chart/transactions/presentation/view/chart_transaction_dataview.dart';

class TransactionPresenter extends CleanArchitecturePresenter<TransactionUseCase, TransactionDataView>{
  TransactionPresenter() : super(TransactionUseCase());

  void loadTransaction(List<TransactionType> type) {
    return useCase.loadTransaction(type, dataView.onTransactionListLoaded);
  }
}