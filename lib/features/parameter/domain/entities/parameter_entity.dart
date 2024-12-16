import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/params/params.dart';

class ParameterEntity {
  final String email;
  final String displayName;
  final String? numero;
  late String? pathImageProfile;
  late String? description;

  ParameterEntity({
    required this.email,
    required this.displayName,
    required this.numero,
    this.pathImageProfile,
    this.description,
  });
  void setImage(String? newPhotoUrl) {
    pathImageProfile = newPhotoUrl;
  }

  void setDetailUser(String? detailUser) {
    description = detailUser;
  }

  factory ParameterEntity.fromUser(User user) {
    return ParameterEntity(
      email: user.email!,
      displayName: user.displayName!,
      numero: user.phoneNumber,
    );
  }

  // Fonction de comparaison avec ParameterParams
  bool isEqualToParams(ParameterParams params) {
    return email == params.email &&
        displayName == params.displayName &&
        numero == params.numero &&
        description == params.description &&
        pathImageProfile == params.pathImageProfile &&
        params.password == "";
  }
}
