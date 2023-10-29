import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../models/menu_model.dart';

abstract class MenuLocalDataSource {
  Future<void> cacheMenu({required MenuModel? menuToCache});
  Future<MenuModel> getLastMenu();
}

const cachedMenu = 'CACHED_TEMPLATE';

class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  final SharedPreferences sharedPreferences;

  MenuLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<MenuModel> getLastMenu() {
    final jsonString = sharedPreferences.getString(cachedMenu);

    if (jsonString != null) {
      return Future.value(MenuModel.fromJson(json: json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMenu({required MenuModel? menuToCache}) async {
    if (menuToCache != null) {
      sharedPreferences.setString(
        cachedMenu,
        json.encode(
          menuToCache.toJson(),
        ),
      );
    } else {
      throw CacheException();
    }
  }
}
