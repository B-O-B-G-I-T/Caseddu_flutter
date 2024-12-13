import 'package:firebase_auth/firebase_auth.dart';

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


}
