import '../../domain/entities/parameter_entity.dart';

class ParameterModel extends ParameterEntity {
  ParameterModel({
    required super.email,
    required super.displayName,
    required super.numero,
    required super.photoUrl,
  });

  factory ParameterModel.fromJson({required Map<String, dynamic> json}) {
    return ParameterModel(
      email: '',
      displayName: '',
      numero: '', photoUrl: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
