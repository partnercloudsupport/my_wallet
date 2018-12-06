import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';
import 'package:flutter/material.dart';

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