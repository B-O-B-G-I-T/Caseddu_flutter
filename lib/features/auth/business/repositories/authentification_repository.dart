import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/features/auth/business/entities/register_entity.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/authentification_entity.dart';

abstract class AuthentificationRepository {
  Future<Either<Failure, AuthentificationEntity>> getAuthentification({
    required AuthentificationParams authentificationParams,
  });

  Future<Either<Failure, RegisterEntity>> createUser({
    required RegisterParams registerParams,
  });
}
