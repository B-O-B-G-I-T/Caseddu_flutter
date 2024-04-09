import 'package:dio/dio.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/params/params.dart';
import '../models/menu_model.dart';

abstract class MenuRemoteDataSource {
  Future<MenuModel> getMenu({required MenuParams menuParams});
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({required this.dio});

  @override
  Future<MenuModel> getMenu({required MenuParams menuParams}) async {
    final response = await dio.get(
      'https://pokeapi.co/api/v2/pokemon/',
      queryParameters: {
        'api_key': 'if needed',
      },
    );

    if (response.statusCode == 200) {
      return MenuModel.fromJson(json: response.data);
    } else {
      throw ServerException();
    }
  }
}
