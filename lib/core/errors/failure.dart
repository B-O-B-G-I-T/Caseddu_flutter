abstract class Failure {
  final String errorMessage;
  const Failure({required this.errorMessage});
}

class ServerFailure extends Failure {
  ServerFailure({required super.errorMessage});
}

class BaseFailure extends Failure {
  BaseFailure({required super.errorMessage});
}

class CacheFailure extends Failure {
  CacheFailure({required super.errorMessage});
}

class ImageFailure extends Failure {
  ImageFailure({required super.errorMessage});
}

class FireBaseFailure extends Failure {
  FireBaseFailure({required super.errorMessage});
}
