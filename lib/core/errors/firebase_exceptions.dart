class ServerException implements Exception {}

// e.code == 'invalid-email'
// e.code == 'wrong-password'
// e.code == 'user-not-found'
class FireBaseException implements Exception {
  late String errMessage;

  FireBaseException({required this.errMessage}) {
    if (errMessage == 'invalid-email') {
      errMessage = "Email invalide";
    } else if (errMessage == 'wrong-password') {
      errMessage = "Mauvais mot de passe";
    } else if (errMessage == 'user-not-found') {
      errMessage = "L'utilisateur n'a pas été trouvé";
    }else if (errMessage == 'network-request-failed') {
      errMessage = "Vérifie la connexion";
    } else {
      errMessage = "Nous n'avons pas identifié le problème";
    }
  }
}

class CacheException implements Exception {}
