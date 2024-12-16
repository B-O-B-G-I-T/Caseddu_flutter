// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../models/qrcode_model.dart';

abstract class QRCodeLocalDataSource {
  Future<void> cacheQRCode({required QRCodeModel? QRCodeToCache});
  Future<QRCodeModel> getLastQRCode();
}

const cachedQRCode = 'CACHED_QRCode';

class QRCodeLocalDataSourceImpl implements QRCodeLocalDataSource {
  final SharedPreferences sharedPreferences;

  QRCodeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<QRCodeModel> getLastQRCode() {
    final jsonString = sharedPreferences.getString(cachedQRCode);

    if (jsonString != null) {
      return Future.value(QRCodeModel.fromJson(json: json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheQRCode({required QRCodeModel? QRCodeToCache}) async {
    if (QRCodeToCache != null) {
      sharedPreferences.setString(
        cachedQRCode,
        json.encode(
          QRCodeToCache.toJson(),
        ),
      );
    } else {
      throw CacheException();
    }
  }
}
