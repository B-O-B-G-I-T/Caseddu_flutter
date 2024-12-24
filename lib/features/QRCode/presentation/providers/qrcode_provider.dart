// ignore_for_file: non_constant_identifier_names

import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/entities/qrcode_entity.dart';
import '../../domain/usecases/get_qrcode.dart';
import '../../data/datasources/qrcode_local_data_source.dart';
import '../../data/datasources/qrcode_remote_data_source.dart';
import '../../data/repositories/qrcode_repository_impl.dart';

class QRCodeProvider extends ChangeNotifier {
  QRCodeEntity? QRCode;
  Failure? failure;

  QRCodeProvider({
    this.QRCode,
    this.failure,
  });

  void eitherFailureOrQRCode() async {
    QRCodeRepositoryImpl repository = QRCodeRepositoryImpl(
      remoteDataSource: QRCodeRemoteDataSourceImpl(
        dio: Dio(),
      ),
      localDataSource: QRCodeLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrQRCode = await GetQRCode(QR_CodeRepository: repository).call(
      QRCodeParams: QRCodeParams(),
    );

    failureOrQRCode.fold(
      (Failure newFailure) {
        QRCode = null;
        failure = newFailure;
        notifyListeners();
      },
      (QRCodeEntity newQRCode) {
        QRCode = newQRCode;
        failure = null;
        notifyListeners();
      },
    );
  }
}
