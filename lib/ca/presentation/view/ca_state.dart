import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/app_material.dart';
export 'package:my_wallet/app_material.dart';

abstract class CleanArchitectureView<ST extends StatefulWidget, T extends CleanArchitecturePresenter> extends State<ST> {
  final T presenter;

  CleanArchitectureView(this.presenter);

  void init();

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    init();
  }

  @override
  void setState(fn) {
    if(this.mounted) super.setState(fn);
  }
}