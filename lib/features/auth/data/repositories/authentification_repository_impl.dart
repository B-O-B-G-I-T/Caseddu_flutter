import 'package:caseddu/features/auth/domain/entities/authentification_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/authentification_repository.dart';
import '../datasources/authentification_remote_data_source.dart';
import '../models/authentification_model.dart';

class AuthentificationRepositoryImpl implements AuthentificationRepository {
  final AuthentificationRemoteDataSource remoteDataSource;

  final NetworkInfo networkInfo;

  AuthentificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthentificationModel>> getAuthentification({required AuthentificationParams authentificationParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        AuthentificationModel remoteAuthentification = await remoteDataSource.getAuthentification(authentificationParams: authentificationParams);

        return Right(remoteAuthentification);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: 'Connecte toi'));
    }
  }

  @override
  Future<Either<Failure, AuthentificationModel>> createUser({required AuthentificationParams authentificationParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        AuthentificationModel remoteAuthentification = await remoteDataSource.createUser(authentificationParams: authentificationParams);

        return Right(remoteAuthentification);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: 'Connecte toi'));
    }
  }

  @override
  Future<Either<Failure, void>> changeMotDePasse({required AuthentificationParams authentificationParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        await remoteDataSource.changeMotDePasse(authentificationParams: authentificationParams);

        return const Right(null);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: 'Connecte toi'));
    }
  }

  @override
  Future<Either<Failure, AuthentificationEntity>> getAuthentificationWithGoogle({required AuthentificationParams authentificationParams}) async {
      if (await networkInfo.isConnected!) {
      try {
        AuthentificationModel remoteAuthentification = await remoteDataSource.createUserWithGoogle(authentificationParams: authentificationParams);

        return Right(remoteAuthentification);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: 'Connecte toi'));
    }
  }

    @override
  Future<Either<Failure, AuthentificationEntity>> getAuthentificationWithApple({required AuthentificationParams authentificationParams}) async {
      if (await networkInfo.isConnected!) {
      try {
        AuthentificationModel remoteAuthentification = await remoteDataSource.createUserWithApple(authentificationParams: authentificationParams);

        return Right(remoteAuthentification);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: 'Connecte toi'));
    }
  }

}
