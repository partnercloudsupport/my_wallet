import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/user/detail/data/detail_repository.dart';

class UserDetailUseCase extends CleanArchitectureUseCase<UserDetailRepository> {
  UserDetailUseCase() : super(UserDetailRepository());

  void loadCurrentUser(onNext<User> next) {
    repo.loadCurrentUser().then((user) => next(user));
  }
}