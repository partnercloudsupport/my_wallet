import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/home/homemain/data/homemain_repository.dart';

class MyWalletHomeUseCase extends CleanArchitectureUseCase<MyWalletHomeRepository> {
  MyWalletHomeUseCase() : super(MyWalletHomeRepository());

  void loadExpense(onNext<List<ExpenseEntity>> next) {
    execute(repo.loadExpense(), next, (e) {
      print("Load expense error $e");
      next([]);
    });
  }

  void resumeDatabase(onNext<bool> next) {
    execute(repo.resumeDatabase(), next, (e) {
      next(false);
    });
  }

  void suspenseStream() {
    execute(repo.dispose(), (_) {}, (_) {});
  }
}