import 'package:dartz/dartz.dart';

import '../core/errors/failure.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call({required P params});
}