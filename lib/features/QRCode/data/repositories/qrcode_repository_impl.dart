// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/qrcode_repository.dart';
import '../datasources/qrcode_local_data_source.dart';
import '../datasources/qrcode_remote_data_source.dart';
import '../models/qrcode_model.dart';

class QRCodeRepositoryImpl implements QRCodeRepository {
  final QRCodeRemoteDataSource remoteDataSource;
  final QRCodeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  QRCodeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, QRCodeModel>> getQRCode(
      {required QRCodeParams qrCodeParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        QRCodeModel remoteQRCode =
            await remoteDataSource.getQRCode(QRCodeParams: qrCodeParams);

        localDataSource.cacheQRCode(QRCodeToCache: remoteQRCode);

        return Right(remoteQRCode);
      } on ServerException {
        return Left(ServerFailure(errorMessage: 'This is a server exception'));
      }
    } else {
      try {
        QRCodeModel localQRCode = await localDataSource.getLastQRCode();
        return Right(localQRCode);
      } on CacheException {
        return Left(CacheFailure(errorMessage: 'This is a cache exception'));
      }
    }
  }
}
