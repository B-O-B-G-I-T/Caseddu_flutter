import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../models/parametre_model.dart';


abstract class ParametreLocalDataSource {
  Future<void> cacheParametre({required ParametreModel? parametreToCache});
  Future<ParametreModel> getLastParametre();
}

const cachedParametre = 'CACHED_TEMPLATE';

class ParametreLocalDataSourceImpl implements ParametreLocalDataSource {
  final SharedPreferences sharedPreferences;

  ParametreLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ParametreModel> getLastParametre() {
    final jsonString = sharedPreferences.getString(cachedParametre);

    if (jsonString != null) {
      return Future.value(ParametreModel.fromJson(json: json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheParametre({required ParametreModel? parametreToCache}) async {
    if (parametreToCache != null) {
      sharedPreferences.setString(
        cachedParametre,
        json.encode(
          parametreToCache.toJson(),
        ),
      );
    } else {
      throw CacheException();
    }
  }
}
