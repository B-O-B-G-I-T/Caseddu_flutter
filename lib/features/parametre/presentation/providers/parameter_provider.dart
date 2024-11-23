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

class ParametreProvider extends ChangeNotifier {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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
