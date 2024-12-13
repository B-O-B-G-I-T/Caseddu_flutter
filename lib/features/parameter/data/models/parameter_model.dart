import '../../domain/entities/parameter_entity.dart';

class ParameterModel extends ParameterEntity {
  ParameterModel({
    required super.email,
    required super.displayName,
    required super.numero,
    required super.pathImageProfile,
    super.description,
  });

  factory ParameterModel.fromJson({required Map<String, dynamic> json}) {
    return ParameterModel(
      email: json['email'],
      displayName: json['displayName'],
      numero: json['numero'] ,
      pathImageProfile: json['photoUrl'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
