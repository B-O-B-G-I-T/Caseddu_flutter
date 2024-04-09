import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/event_entity.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventEntity> appointments) {
    this.appointments = appointments;
  }

  EventEntity getEvent(int index) => appointments![index] as EventEntity;

  @override
  DateTime getStartTime(int index) => getEvent(index).deQuand;

  @override
  DateTime getEndTime(int index) => getEvent(index).aQuand;

  @override
  String getSubject(int index) => getEvent(index).title;

  @override
  Color getColor(int index) => getEvent(index).backgroundColor;
  
  String getRecurence(int index) => getEvent(index).recurrence;

}
