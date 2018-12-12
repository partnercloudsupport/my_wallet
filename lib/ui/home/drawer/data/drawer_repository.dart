import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase_manager.dart' as fm;

class LeftDrawerRepository extends CleanArchitectureRepository {
  Future<bool> signOut() {
    return fm.signOut();
  }
}