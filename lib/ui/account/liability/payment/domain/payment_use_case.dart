import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/account/liability/payment/data/payment_repository.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

class PayLiabilityUseCase extends CleanArchitectureUseCase<PayLiabilityRepository> {
  PayLiabilityUseCase() : super(PayLiabilityRepository());

  void loadAccounts(int exceptId, onNext<List<Account>> next, onError error) {
    execute(repo.loadAccountsExceptId(exceptId), next, error);
  }

  void loadCategories(onNext<List<AppCategory>> next, onError error) {
    execute(repo.loadCategories(), next, error);
  }

  void savePayment(int liabilityId, Account fromAccount, AppCategory category, double amount, DateTime date, onNext<bool> next, onError error) {
    execute(Future(() async {
      // Create a dischargeOfLiability transaction
      var id = await repo.generateDischargeLiabilityId();

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String userUid = sharedPreferences.getString(UserUUID);

      DischargeOfLiability discharge = DischargeOfLiability(id, date, liabilityId, fromAccount.id, category.id, amount, userUid);

      return repo.saveDischargeOfLiability(discharge);
    }), next, error);
  }
}