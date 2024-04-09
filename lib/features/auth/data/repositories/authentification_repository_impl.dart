import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/auth/business/entities/register_entity.dart';
import 'package:flutter_application_1/features/auth/data/models/register_model.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../business/repositories/authentification_repository.dart';
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
    } on FireBaseException catch (e){
      return Left(ServerFailure(errorMessage: e.errMessage));
    }
  }

  @override
  Future<Either<Failure, RegisterEntity>> createUser({required RegisterParams registerParams}) async {
   try {
      RegisterModel remoteAuthentification = await remoteDataSource.createUser(registerParams: registerParams);

      return Right(remoteAuthentification);
    } on ServerException {
      return Left(ServerFailure(errorMessage: 'This is a server exception'));
    }
    
  }
}
