import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';

class EventModel extends EventEntity {
  const EventModel(
      {required String title,
      required String description,
      required DateTime from,
      required DateTime to,
      required Color backgroundColor,
      required String recurrence})
      : super(title: title, description: description, from: from, to: to, backgroundColor: backgroundColor, recurrence: recurrence);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'],
      description: json['description'],
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
      backgroundColor: Color(json['backgroundColor']),
      recurrence: json['recurrence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'backgroundColor': backgroundColor.value,
      'recurrence': recurrence,
    };
  }
}
