import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../data/datasources/parameter_local_data_source.dart';
import '../../data/datasources/parameter_remote_data_source.dart';
import '../../data/repositories/parameter_repository_impl.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/usecases/get_parameter.dart';

class ParameterProvider extends ChangeNotifier {
  ParameterEntity? parameter;
  Failure? failure;

  ParameterProvider({
    this.parameter,
    this.failure,
  });

  Future<void> init() async {
    final User user = FirebaseAuth.instance.currentUser!;
    parameter = ParameterEntity.fromUser(user);
  }

  void eitherFailureOrLogout() async {
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

    final failureOrParametre = await GetParametre(parametreRepository: repository).call();

    failureOrParametre.fold(
      (Failure newFailure) {
        parameter = null;
        failure = newFailure;
        notifyListeners();
      },
      (void d) {
        failure = null;
        notifyListeners();
      },
    );
  }

  void eitherFailureOrUpdate({required ParameterParams parameterParams}) async {
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

    final failureOrParametre = await GetParametre(parametreRepository: repository).update(
      parametreParams: parameterParams,
    );

    failureOrParametre.fold(
      (Failure newFailure) {
        parameter = null;
        failure = newFailure;
        notifyListeners();
      },
      (ParameterEntity parameterEntity) {
        failure = null;
        parameter = parameterEntity;
        notifyListeners();
      },
    );
  }
}
