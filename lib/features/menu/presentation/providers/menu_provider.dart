import 'package:data_connection_checker_tv/data_connection_checker.dart';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/usecases/get_menu.dart';
import '../../data/datasources/menu_local_data_source.dart';
import '../../data/datasources/menu_remote_data_source.dart';
import '../../data/repositories/menu_repository_impl.dart';

class MenuProvider extends ChangeNotifier {
  MenuEntity? menu;
  Failure? failure;

  MenuProvider({
    this.menu,
    this.failure,
  });

  void eitherFailureOrMenu() async {
    MenuRepositoryImpl repository = MenuRepositoryImpl(
      remoteDataSource: MenuRemoteDataSourceImpl(
        dio: Dio(),
      ),
      localDataSource: MenuLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrMenu = await GetMenu(menuRepository: repository).call(
      menuParams: MenuParams(),
    );

    failureOrMenu.fold(
      (Failure newFailure) {
        menu = null;
        failure = newFailure;
        notifyListeners();
      },
      (MenuEntity newMenu) {
        menu = newMenu;
        failure = null;
        notifyListeners();
      },
    );
  }
}
