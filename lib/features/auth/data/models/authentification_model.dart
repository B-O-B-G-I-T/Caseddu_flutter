import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/constants/constants.dart';
import '../../business/entities/authentification_entity.dart';

class AuthentificationModel extends AuthentificationEntity {
  const AuthentificationModel({
    required String email, required String pseudo
  }) : super(
          email: email, pseudo: pseudo
        );

  factory AuthentificationModel.fromJson({required User user}) {
    return AuthentificationModel(
      email: user.email!,
      pseudo: user.displayName!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kEmail: email,
      kPassword: pseudo
    };
  }
}
