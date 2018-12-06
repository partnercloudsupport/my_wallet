import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

class CleanArchitecturePresenter<T extends CleanArchitectureUseCase, DV extends DataView> {
  final T useCase;
  DV dataView;

  CleanArchitecturePresenter(this.useCase);
}