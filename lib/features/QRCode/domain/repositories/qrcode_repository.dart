// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/qrcode_entity.dart';


abstract class QRCodeRepository {
  Future<Either<Failure, QRCodeEntity>> getQRCode({
    required QRCodeParams qrCodeParams,
  });
}
