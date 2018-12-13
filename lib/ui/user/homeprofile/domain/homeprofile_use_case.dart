import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/user/homeprofile/data/homeprofile_repository.dart';

class HomeProfileUseCase extends CleanArchitectureUseCase<HomeProfileRepository> {
  HomeProfileUseCase() : super(HomeProfileRepository());
}