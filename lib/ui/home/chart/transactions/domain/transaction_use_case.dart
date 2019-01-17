import 'package:my_wallet/ui/home/chart/transactions/data/transaction_repository.dart';
import 'package:my_wallet/ui/home/chart/transactions/data/transaction_entity.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/data/data.dart';

class TransactionUseCase extends CleanArchitectureUseCase<TransactionRepository>{
  TransactionUseCase() : super(TransactionRepository());

  void loadTransaction(List<TransactionType> type, onNext<List<TransactionEntity>> next) {
    execute<List<TransactionEntity>>(repo.loadTransaction(type), next);
  }
}