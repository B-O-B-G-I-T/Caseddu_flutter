import 'package:dartz/dartz.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/authentification_repository.dart';
import '../datasources/authentification_remote_data_source.dart';
import '../models/authentification_model.dart';

class AuthentificationRepositoryImpl implements AuthentificationRepository {
  final AuthentificationRemoteDataSource remoteDataSource;

  AuthentificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, AuthentificationModel>> getAuthentification({required AuthentificationParams authentificationParams}) async {
    try {
      AuthentificationModel remoteAuthentification = await remoteDataSource.getAuthentification(authentificationParams: authentificationParams);

      return Right(remoteAuthentification);
    } on FireBaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.errMessage));
    }
  }

  @override
  Future<Either<Failure, AuthentificationModel>> createUser({required AuthentificationParams authentificationParams}) async {
    try {
      AuthentificationModel remoteAuthentification = await remoteDataSource.createUser(authentificationParams: authentificationParams);

      return Right(remoteAuthentification);
    } on FireBaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.errMessage));
    }
  }

  @override
  Future<Either<Failure, void>> changeMotDePasse({required AuthentificationParams authentificationParams}) async {
    try {
      await remoteDataSource.changeMotDePasse(authentificationParams: authentificationParams);

      return const Right(null);
    } on FireBaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.errMessage));
    }
  }
}
