import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/home/homemain/data/homemain_repository.dart';

class MyWalletHomeUseCase extends CleanArchitectureUseCase<MyWalletHomeRepository> {
  MyWalletHomeUseCase() : super(MyWalletHomeRepository());

  void loadExpense(onNext<List<ExpenseEntity>> next) {
    repo.loadExpense().then((value) => next(value));
  }
}