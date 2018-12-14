import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/budget/detail/data/detail_repository.dart';

class BudgetDetailUseCase extends CleanArchitectureUseCase<BudgetDetailRepository> {
  BudgetDetailUseCase() : super(BudgetDetailRepository());
}