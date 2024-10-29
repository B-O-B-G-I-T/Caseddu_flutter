import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/authentification_entity.dart';

abstract class AuthentificationRepository {
  Future<Either<Failure, AuthentificationEntity>> getAuthentification({
    required AuthentificationParams authentificationParams,
  });

  Future<Either<Failure, AuthentificationEntity>> createUser({
    required AuthentificationParams authentificationParams,
  });
  Future<Either<Failure, AuthentificationEntity>> getAuthentificationWithGoogle({
    required AuthentificationParams authentificationParams,
  });
  Future<Either<Failure, AuthentificationEntity>> getAuthentificationWithApple({
    required AuthentificationParams authentificationParams,
  });

  Future<Either<Failure, void>> changeMotDePasse({
    required AuthentificationParams authentificationParams,
  });
}
