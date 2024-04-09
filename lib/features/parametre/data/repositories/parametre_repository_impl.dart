import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/features/parametre/data/datasources/parametre_local_data_source.dart';
import 'package:flutter_application_1/features/parametre/data/datasources/parametre_remote_data_source.dart';
import 'package:flutter_application_1/features/parametre/data/models/parametre_model.dart';
import 'package:flutter_application_1/features/parametre/domain/repositories/parametre_repository.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';

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
  Future<Either<Failure, void>> deconnexion({required ParametreParams parametreParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        await remoteDataSource.deconnexion(parametreParams: parametreParams);

        return const Right(null);
      } on FireBaseException catch (e) {
        return Left(ServerFailure(errorMessage: e.errMessage));
      }
    } else {
      return Left(ServerFailure(errorMessage: "Connecte toi à l'internet"));
    }
  }
}
