import 'package:firebase_auth/firebase_auth.dart';

class ParameterEntity {
  final String email;
  final String displayName;
  final String? numero;

  ParameterEntity({
    required this.email,
    required this.displayName,
    required this.numero,
  });

  factory ParameterEntity.fromUser(User user) {
    return ParameterEntity(
      email: user.email!,
      displayName: user.displayName!,
      numero: user.phoneNumber,
    );
  }
}
