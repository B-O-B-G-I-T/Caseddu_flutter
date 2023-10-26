import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/business/entities/register_entity.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../business/entities/authentification_entity.dart';
import '../../business/usecases/get_authentification.dart';

import '../../data/datasources/authentification_remote_data_source.dart';
import '../../data/repositories/authentification_repository_impl.dart';

class AuthentificationProvider extends ChangeNotifier {
  AuthentificationEntity? authentification;
  RegisterEntity? register;
  Failure? failure;

  AuthentificationProvider({this.authentification, this.failure, this.register});

  void eitherFailureOrAuthentification(String email, String password) async {
    failure = null;
    AuthentificationRepositoryImpl repository = AuthentificationRepositoryImpl(
      remoteDataSource: AuthentificationRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
      ),
    );

    final failureOrAuthentification = await GetAuthentification(authentificationRepository: repository).call(
      authentificationParams: AuthentificationParams(
        email: email,
        password: password,
      ),
    );

    failureOrAuthentification.fold(
      (Failure newFailure) {
        authentification = null;
        failure = newFailure;
        notifyListeners();
      },
      (AuthentificationEntity newAuthentification) {
        authentification = newAuthentification;
        failure = null;
        notifyListeners();
      },
    );
  }

  void eitherFailureOrRegister(String email, String password, String confirmPassword, String numero, String pseudo) async {
    failure = null;
    AuthentificationRepositoryImpl repository = AuthentificationRepositoryImpl(
      remoteDataSource: AuthentificationRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
      ),
    );

    final failureOrAuthentification = await GetAuthentification(authentificationRepository: repository).create(
      registerParams: RegisterParams(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        numero: numero,
        pseudo: pseudo,
      ),
    );

    failureOrAuthentification.fold(
      (Failure newFailure) {
        register = null;
        failure = newFailure;
        notifyListeners();
      },
      (RegisterEntity newAuthentification) {
        register = newAuthentification;
        failure = null;
        notifyListeners();
      },
    );
  }
}
