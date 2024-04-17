import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';

class EventModel extends EventEntity {
  const EventModel(
      {required String title,
      required String description,
      required DateTime deQuand,
      required DateTime aQuand,
      required Color backgroundColor,
      required String recurrence})
      : super(title: title, description: description, deQuand: deQuand, aQuand: aQuand, backgroundColor: backgroundColor, recurrence: recurrence);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'],
      description: json['description'],
      deQuand: DateTime.parse(json['deQuand']),
      aQuand: DateTime.parse(json['aQuand']),
      backgroundColor: Color(json['backgroundColor']),
      recurrence: json['recurrence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deQuand': deQuand.toIso8601String(),
      'aQuand': aQuand.toIso8601String(),
      'backgroundColor': backgroundColor.value,
      'recurrence': recurrence,
    };
  }
}
