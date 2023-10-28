import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../../../core/connection/network_info.dart';
import '../../domain/entities/authentification_entity.dart';
import '../../domain/usecases/get_authentification.dart';

import '../../data/datasources/authentification_remote_data_source.dart';
import '../../data/repositories/authentification_repository_impl.dart';

class AuthentificationProvider extends ChangeNotifier {
  AuthentificationEntity? authentification;
  Failure? failure;
  FirebaseAuth firebaseAuth;

  AuthentificationProvider({this.authentification, this.failure, required this.firebaseAuth});

  Future eitherFailureOrAuthentification(String email, String password) async {
    AuthentificationRepositoryImpl repository = AuthentificationRepositoryImpl(
      remoteDataSource: AuthentificationRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrAuthentification = await GetAuthentification(authentificationRepository: repository).call(
      authentificationParams: AuthentificationParams(
        email: email,
        password: password,
      ),
    );

    return failureOrAuthentification.fold(
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

  Future eitherFailureOrRegister(String email, String password, String confirmPassword, String numero, String pseudo) async {
    AuthentificationRepositoryImpl repository = AuthentificationRepositoryImpl(
      remoteDataSource: AuthentificationRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
      ), networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrAuthentification = await GetAuthentification(authentificationRepository: repository).create(
      authentificationParams: AuthentificationParams(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        numero: numero,
        pseudo: pseudo,
      ),
    );

    return failureOrAuthentification.fold(
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

  Future eitherFailureOrPasswordChange(
    String email,
  ) async {
    AuthentificationRepositoryImpl repository = AuthentificationRepositoryImpl(
      remoteDataSource: AuthentificationRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
      ), networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrAuthentification = await GetAuthentification(authentificationRepository: repository).changeMotDePasse(
      authentificationParams: AuthentificationParams(
        email: email,
      ),
    );

    return failureOrAuthentification.fold(
      (Failure newFailure) {
        authentification = null;
        failure = newFailure;
        notifyListeners();
      },
      (void chelou) {
        authentification = null;
        failure = null;
        notifyListeners();
      },
    );
  }
}
