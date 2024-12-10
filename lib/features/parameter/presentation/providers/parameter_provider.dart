import 'package:caseddu/core/utils/images/utils_image.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
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
  late ParameterEntity parameter;

  // gestion des images du data picker
  List<AssetEntity> images = [];
  List<AssetEntity> selectedImages = [];

  Failure? failure;

  ParameterProvider({

    this.failure,
  });

  Future<void> init() async {
    final User user = FirebaseAuth.instance.currentUser!;
    parameter = ParameterEntity.fromUser(user);
    eitherFailureOrGetSavedProfileImage();
    //notifyListeners();
  }

  Future<void> loadImageParams(BuildContext context) async {
    images = await loadImages(context);
    notifyListeners();
  }

  void toggleSelection(AssetEntity image) {
    final currentSelection = selectedImages;
    if (currentSelection.contains(image)) {
      currentSelection.remove(image);
    } else if (currentSelection.isNotEmpty) {
      currentSelection.clear();
      currentSelection.add(image);
    } else {
      currentSelection.add(image);
    }
    selectedImages = currentSelection;
    notifyListeners();
  }

  Future<void> eitherFailureOrSelectedImageProfile(AssetEntity image) async {
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

    final failureOrParametre = await GetParametre(parametreRepository: repository).selectedImageProfile(image);

    failureOrParametre.fold(
      (Failure newFailure) {

        failure = newFailure;
        notifyListeners();
      },
      (String imagePath) {
        failure = null;
        parameter.setImage(imagePath);

        notifyListeners();
      },
    );
  }

  void eitherFailureOrGetSavedProfileImage() async {
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

    final failureOrParametre = await GetParametre(parametreRepository: repository).getSavedProfileImage();

    failureOrParametre.fold(
      (Failure newFailure) {

        failure = newFailure;
        notifyListeners();
      },
      (String? imagePath) {
        failure = null;
        parameter.setImage(imagePath);
        notifyListeners();
      },
    );
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
