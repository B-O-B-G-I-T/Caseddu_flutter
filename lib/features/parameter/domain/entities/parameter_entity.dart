import 'package:firebase_auth/firebase_auth.dart';

class ParameterEntity {
  final String email;
  final String displayName;
  final String? numero;
  late String? photoUrl;

  ParameterEntity({
    required this.email,
    required this.displayName,
    required this.numero,
    required this.photoUrl,
  });
  void setImage(String? newPhotoUrl) {
    photoUrl = newPhotoUrl;
  }

  factory ParameterEntity.fromUser(User user) {
    return ParameterEntity(
      email: user.email!,
      displayName: user.displayName!,
      numero: user.phoneNumber,
      photoUrl: "user.photoURL",
    );
  }
}
