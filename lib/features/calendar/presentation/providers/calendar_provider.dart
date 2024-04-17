import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/usecases/get_event.dart';
import '../../data/datasources/event_local_data_source.dart';
import '../../data/datasources/event_remote_data_source.dart';
import '../../data/repositories/event_repository_impl.dart';

class CalendarProvider extends ChangeNotifier {
  EventEntity? event;
  Failure? failure;

  final List<EventEntity> _events = [];

  CalendarProvider({
    this.event,
    this.failure,
  });

  List<EventEntity> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<EventEntity> get eventsSelectedDate => _events;

  void addEvent(EventEntity event) {
    _events.add(event);

    notifyListeners();
  }

  void deleteEvent(EventEntity event) {
    _events.remove(event);

    notifyListeners();
  }

  void editEvent(EventEntity newEvent, EventEntity oldEvent) {
    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;
    notifyListeners();
  }

  void eitherFailureOrAjoutEvenement(EventParams eventParams) async {
    EventRepositoryImpl repository = EventRepositoryImpl(
      remoteDataSource: EventRemoteDataSourceImpl(
        dio: Dio(),
      ),
      localDataSource: EventLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );


    final failureOrEvent = await GetEvent(eventRepository: repository).ajoutEvenement(
      eventParams: eventParams,
    );

    failureOrEvent.fold(
      (Failure newFailure) {
        event = null;
        failure = newFailure;
        notifyListeners();
      },
      (EventEntity eventEntity) {
        _events.add(eventEntity);
        failure = null;
        notifyListeners();
      },
    );
  }
}
