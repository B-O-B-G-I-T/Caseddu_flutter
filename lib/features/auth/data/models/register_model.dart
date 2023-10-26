import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/auth/business/entities/register_entity.dart';

import '../../../../../core/constants/constants.dart';

class RegisterModel extends RegisterEntity {
  const RegisterModel({
    required String email, required String pseudo, required String numero
  }) : super(
          email: email, pseudo: pseudo, numero: numero
        );

  factory RegisterModel.fromJson({required User user}) {
    return RegisterModel(
      email: user.email!,
      pseudo: user.displayName!,
      numero: user.phoneNumber!
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kEmail: email,
      kPassword: pseudo,
      kNumero: numero
    };
  }
}
