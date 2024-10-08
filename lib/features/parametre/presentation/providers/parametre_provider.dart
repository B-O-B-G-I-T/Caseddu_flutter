import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../data/datasources/parametre_local_data_source.dart';
import '../../data/datasources/parametre_remote_data_source.dart';
import '../../data/repositories/parametre_repository_impl.dart';
import '../../domain/entities/parametre_entity.dart';
import '../../domain/usecases/parametre_template.dart';

class ParametreProvider extends ChangeNotifier {
  ParametreEntity? parametre;
  Failure? failure;

  ParametreProvider({
    this.parametre,
    this.failure,
  });

  void eitherFailureOrParametre() async {
    ParametreRepositoryImpl repository = ParametreRepositoryImpl(
      remoteDataSource: ParametreRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
      ),
      localDataSource: ParametreLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrParametre = await GetParametre(parametreRepository: repository).call(
      parametreParams: ParametreParams(),
    );

    failureOrParametre.fold(
      (Failure newFailure) {
        parametre = null;
        failure = newFailure;
        notifyListeners();
      },
      (void d) {

        failure = null;
        notifyListeners();
      },
    );
  }
}
