import '../../domain/entities/parameter_entity.dart';

class ParameterModel extends ParameterEntity {
  ParameterModel({
    required super.email,
    required super.displayName,
    required super.numero,
  });

  factory ParameterModel.fromJson({required Map<String, dynamic> json}) {
    return ParameterModel(
      email: '',
      displayName: '',
      numero: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
