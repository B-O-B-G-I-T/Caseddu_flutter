import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/constants/constants.dart';
import '../../domain/entities/authentification_entity.dart';

class AuthentificationModel extends AuthentificationEntity {
  const AuthentificationModel({
    required String email, String? pseudo, String? numero,
  }) : super(
          email: email, pseudo: pseudo, numero:numero
        );

  factory AuthentificationModel.fromJson({required User user}) {
    return AuthentificationModel(
      email: user.email!,
      pseudo: user.displayName,
      numero: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kEmail: email,
      kPassword: pseudo,
      kNumero: numero,
    };
  }
}