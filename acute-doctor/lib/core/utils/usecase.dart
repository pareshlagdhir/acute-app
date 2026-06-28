import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Base contract for use cases.
///
/// Implement `call(Params)` and return `Either<Failure, T>`.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Marker for use cases that take no parameters.
class NoParams {
  const NoParams();
}
