import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../models/event_model.dart';

abstract class EventLocalDataSource {
  Future<void> cacheEvent({required EventModel? eventToCache});
  Future<EventModel> getLastEvent();
}

const cachedEvent = 'CACHED_TEMPLATE';

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final SharedPreferences sharedPreferences;

  EventLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<EventModel> getLastEvent() {
    final jsonString = sharedPreferences.getString(cachedEvent);

    if (jsonString != null) {
      return Future.value(EventModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheEvent({required EventModel? eventToCache}) async {
    if (eventToCache != null) {
      sharedPreferences.setString(
        cachedEvent,
        json.encode(
          eventToCache.toJson(),
        ),
      );
    } else {
      throw CacheException();
    }
  }
}
