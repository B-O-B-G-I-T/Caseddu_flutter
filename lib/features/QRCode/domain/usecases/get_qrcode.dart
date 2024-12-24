// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/qrcode_entity.dart';
import '../repositories/qrcode_repository.dart';


class GetQRCode {
  final QRCodeRepository QR_CodeRepository;

  GetQRCode({required this.QR_CodeRepository});

  Future<Either<Failure, QRCodeEntity>> call({
    required QRCodeParams QRCodeParams,
  }) async {
    return await QR_CodeRepository.getQRCode(qrCodeParams: QRCodeParams);
  }
}


