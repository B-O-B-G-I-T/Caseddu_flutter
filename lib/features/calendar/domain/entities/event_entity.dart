import 'package:flutter/material.dart';

class EventEntity {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final String recurrence;

  const EventEntity({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    this.backgroundColor = Colors.lightGreen,
    this.recurrence = 'Jamais',
  });
}
