import 'package:caseddu/features/parameter/domain/entities/parameter_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../datasources/parameter_local_data_source.dart';
import '../datasources/parameter_remote_data_source.dart';

class ParametreRepositoryImpl implements ParametreRepository {
  final ParametreRemoteDataSource remoteDataSource;
  final ParametreLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ParametreRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
// TODO faire une deconnexion qui fonctionne hors réseaux
  @override
  Future<Either<Failure, void>> deconnexion() async {
    if (await networkInfo.isConnected!) {
      try {
        await remoteDataSource.deconnexion();

        return const Right(null);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: "Connecte toi à l'internet"));
    }
  }

  @override
  Future<Either<Failure, ParameterEntity>> update({required ParameterParams parametreParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        final ParameterEntity parameterEntity = await remoteDataSource.update(parametreParams: parametreParams);

        return Right(parameterEntity);
      } on FireBaseException catch (e) {
        return Left(FireBaseFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: "Connecte toi à l'internet"));
    }
  }

  @override
  Future<Either<Failure, String>> selectedImageProfile(AssetEntity image) async {
    if (await networkInfo.isConnected!) {
      try {
        String path = await localDataSource.saveImageProfile(image);

        return Right(path);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: "Connecte toi à l'internet"));
    }
  }
  
  @override
  Future<Either<Failure, String?>> getSavedProfileImage() async {

      try {
        String? path = await localDataSource.getSavedProfileImage();

        return Right(path);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } 
  @override
  Future<Either<Failure, String?>> getDetailUser() async {

      try {
        String? path = await localDataSource.getDetailUser();

        return Right(path);
      } on FireBaseException catch (e) {
        return Left(BaseFailure(errorMessage: e.errMessage));
      }
    
  }
  
  @override
  Future<Either<Failure, void>> insertDetailUser(String? insertUserDetail) async {
    
    try {
      await localDataSource.insertDetailUser(insertUserDetail);

      return const Right(null);
    } on FireBaseException catch (e) {
      return Left(BaseFailure(errorMessage: e.errMessage));
    }
  }
}
