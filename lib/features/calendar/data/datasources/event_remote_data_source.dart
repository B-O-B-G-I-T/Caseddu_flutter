import 'package:dio/dio.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/params/params.dart';
import '../models/event_model.dart';


abstract class EventRemoteDataSource {
  Future<EventModel> getEvent({required EventParams eventParams});
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl({required this.dio});

  @override
  Future<EventModel> getEvent({required EventParams eventParams}) async {
    final response = await dio.get(
      'https://pokeapi.co/api/v2/pokemon/',
      queryParameters: {
        'api_key': 'if needed',
      },
    );

    if (response.statusCode == 200) {
      return EventModel.fromJson(response.data);
    } else {
      throw ServerException();
    }
  }
}
