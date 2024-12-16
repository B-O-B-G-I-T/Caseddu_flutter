// ignore_for_file: non_constant_identifier_names

import '../../../../../core/constants/constants.dart';
import '../../domain/entities/qrcode_entity.dart';

class QRCodeModel extends QRCodeEntity {
  const QRCodeModel({
    required super.QRCode,
  });

  factory QRCodeModel.fromJson({required Map<String, dynamic> json}) {
    return QRCodeModel(
      QRCode: json[kQRCode],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kQRCode: QRCode,
    };
  }
}
