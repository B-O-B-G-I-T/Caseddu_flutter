import 'package:flutter/material.dart';

class EventEntity {
  final String title;
  final String description;
  final DateTime deQuand;
  final DateTime aQuand;
  final Color backgroundColor;
  final String recurrence;

  const EventEntity({
    required this.title,
    required this.description,
    required this.deQuand,
    required this.aQuand,
    this.backgroundColor = Colors.lightGreen,
    this.recurrence = 'Jamais',
  });
}
