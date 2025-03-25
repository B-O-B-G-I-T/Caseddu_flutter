// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../../../common/usecas.dart';
import '../entities/qrcode_entity.dart';
import '../repositories/qrcode_repository.dart';

class GetQRCode implements UseCase<QRCodeEntity, QRCodeParams> {
  final QRCodeRepository QR_CodeRepository;

  GetQRCode({required this.QR_CodeRepository});
  @override
  Future<Either<Failure, QRCodeEntity>> call({
    required QRCodeParams params,
  }) async {
    return await QR_CodeRepository.getQRCode(qrCodeParams: params);
  }
}


