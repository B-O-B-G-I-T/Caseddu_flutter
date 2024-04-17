import 'package:dartz/dartz.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_local_data_source.dart';
import '../datasources/menu_remote_data_source.dart';
import '../models/menu_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;
  final MenuLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MenuRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MenuModel>> getMenu(
      {required MenuParams menuParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        MenuModel remoteMenu =
            await remoteDataSource.getMenu(menuParams: menuParams);

        localDataSource.cacheMenu(menuToCache: remoteMenu);

        return Right(remoteMenu);
      } on ServerException {
        return Left(ServerFailure(errorMessage: 'This is a server exception'));
      }
    } else {
      try {
        MenuModel localMenu = await localDataSource.getLastMenu();
        return Right(localMenu);
      } on CacheException {
        return Left(CacheFailure(errorMessage: 'This is a cache exception'));
      }
    }
  }
}
