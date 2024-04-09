import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/features/auth/business/entities/register_entity.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/authentification_entity.dart';
import '../repositories/authentification_repository.dart';

class GetAuthentification {
  final AuthentificationRepository authentificationRepository;

  GetAuthentification({required this.authentificationRepository});

  Future<Either<Failure, AuthentificationEntity>> call({
    required AuthentificationParams authentificationParams,
  }) async {
    return await authentificationRepository.getAuthentification(authentificationParams: authentificationParams);
  }

  Future<Either<Failure, RegisterEntity>> create({
    required RegisterParams registerParams,
  }) async {
    return await authentificationRepository.createUser(registerParams: registerParams);
  }
}
