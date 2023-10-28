import 'package:flutter_application_1/core/constants/constants.dart';
import 'package:flutter_application_1/features/parametre/domain/entities/parametre_entity.dart';

class ParametreModel extends ParametreEntity {
  const ParametreModel({
    required String parametre,
  }) : super(
          parametre: parametre,
        );

  factory ParametreModel.fromJson({required Map<String, dynamic> json}) {
    return ParametreModel(
      parametre: json[kParametre],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kParametre: parametre,
    };
  }
}
