
import '../../../../core/constants/constants.dart';
import '../../domain/entities/parametre_entity.dart';

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
