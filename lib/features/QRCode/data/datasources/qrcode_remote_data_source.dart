// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/params/params.dart';
import '../models/qrcode_model.dart';

abstract class QRCodeRemoteDataSource {
  Future<QRCodeModel> getQRCode({required QRCodeParams QRCodeParams});
}

class QRCodeRemoteDataSourceImpl implements QRCodeRemoteDataSource {
  final Dio dio;

  QRCodeRemoteDataSourceImpl({required this.dio});

  @override
  Future<QRCodeModel> getQRCode({required QRCodeParams QRCodeParams}) async {
    final response = await dio.get(
      'https://pokeapi.co/api/v2/pokemon/',
      queryParameters: {
        'api_key': 'if needed',
      },
    );

    if (response.statusCode == 200) {
      return QRCodeModel.fromJson(json: response.data);
    } else {
      throw ServerException();
    }
  }
}
