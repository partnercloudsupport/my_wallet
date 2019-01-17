import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ca/domain/ca_default_response.dart';
export 'package:my_wallet/ca/domain/ca_default_response.dart';

import 'package:rxdart/rxdart.dart';
export 'package:rxdart/rxdart.dart';
/// Free flow, use your repo as you wish in your own usecase, and return data as you need
class CleanArchitectureUseCase<T extends CleanArchitectureRepository> {
  final T repo;

  CleanArchitectureUseCase(this.repo);

  void execute<T>(Future<T> task, onNext<T> next, {onError error}) {
    Observable(Stream.fromFuture(task)).listen((data) => next(data), onError: (e, stacktrace) {
      print(stacktrace);

      if(e is Exception) {
        error(e);
      } else {
        error(Exception(e.toString()));
      }
    });
  }
}
