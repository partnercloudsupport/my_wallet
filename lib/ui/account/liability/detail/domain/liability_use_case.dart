import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/account/liability/detail/data/liability_repository.dart';

class LiabilityUseCase extends CleanArchitectureUseCase<LiabilityRepository> {
  LiabilityUseCase() : super(LiabilityRepository());

  void loadAccountInfo(int id, onNext<Account> next, onError error) {
    execute(repo.loadAccountInfo(id), next,error);
  }
}