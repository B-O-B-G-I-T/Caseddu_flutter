
import '../../../../core/constants/constants.dart';
import '../../domain/entities/parameter_entity.dart';

class ParametreModel extends ParametreEntity {
  const ParametreModel({
    required super.parametre,
  });

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
