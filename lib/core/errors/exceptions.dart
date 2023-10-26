class ServerException implements Exception {}

class FireBaseException implements Exception {
  final String errMessage;

  FireBaseException({required this.errMessage});
  
}

class CacheException implements Exception {}
