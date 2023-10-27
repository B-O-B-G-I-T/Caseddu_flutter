import 'package:dartz/dartz.dart';
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

  Future<Either<Failure, AuthentificationEntity>> create({
    required AuthentificationParams authentificationParams,
  }) async {
    return await authentificationRepository.createUser(authentificationParams: authentificationParams);
  }

  Future<Either<Failure, void>> changeMotDePasse({
    required AuthentificationParams authentificationParams,
  }) async {
    return await authentificationRepository.changeMotDePasse(authentificationParams: authentificationParams);
    
  }
}
