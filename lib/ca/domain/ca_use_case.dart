import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ca/domain/ca_default_response.dart';
export 'package:my_wallet/ca/domain/ca_default_response.dart';

import 'package:rxdart/rxdart.dart';
export 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart';
export 'package:flutter/foundation.dart';
/// Free flow, use your repo as you wish in your own usecase, and return data as you need
class CleanArchitectureUseCase<T extends CleanArchitectureRepository> {
  final T repo;

  CleanArchitectureUseCase(this.repo);

  void execute<T>(Future<T> task, onNext<T> next, onError error) {
    if(task != null) {
      Observable(Stream.fromFuture(task)).listen((data) => next(data), onError: (e, stacktrace) {
        debugPrint(stacktrace);

        if (error != null) {
          if (e is Exception) {
            error(e);
          } else {
            error(Exception(e.toString()));
          }
        }
      });
    } else {
      debugPrint("task is null: $task ${this.toString()}");
    }
  }
}
