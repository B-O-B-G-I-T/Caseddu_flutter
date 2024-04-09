import 'package:caseddu/features/calendar/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import '../../features/chat/data/models/chat_message_model.dart';

class NoParams {}

class TemplateParams {}

class PokemonParams {
  final String id;
  const PokemonParams({
    required this.id,
  });
}

class AuthentificationParams {
  final String email;
  final String? pseudo;
  final String? password;
  final String? confirmPassword;
  final String? numero;
  AuthentificationParams({required this.email, this.password, this.confirmPassword, this.numero, this.pseudo});
}

class ParametreParams {}

class MenuParams {}

class ChatMessageParams {
  String id = '';
  String sender = '';
  String receiver = '';
  String message = '';
  String images = '';
  String type = 'Payload';
  String sendOrReceived = '';
  DateTime timestamp = DateTime.now();
  bool broadcast = true;
  NearbyService? _nearbyService;

  ChatMessageParams(
    this.id,
    this.sender,
    this.receiver,
    this.message,
    this.images,
    this.type,
    this.sendOrReceived,
    this.timestamp, {
    NearbyService? nearbyService,
  }) : _nearbyService = nearbyService;

  set nearbyService(NearbyService? nearbyService) {
    _nearbyService = nearbyService;
  }

  NearbyService? get nearbyService => _nearbyService;

  ChatMessageModel toModel() {
    return ChatMessageModel(
      id: id,
      sender: sender,
      receiver: receiver,
      message: message,
      images: images,
      type: type,
      timestamp: timestamp,
    );
  }
}

class EventParams {
  final String title;
  final String description;
  final DateTime deQuand;
  final DateTime aQuand;
  final Color backgroundColor;
  final String recurrence;

  const EventParams({
    required this.title,
    required this.description,
    required this.deQuand,
    required this.aQuand,
    this.backgroundColor = Colors.lightGreen,
    this.recurrence = 'Jamais',
  });

  EventModel toEventModel() {
    return EventModel(
      title: title,
      description: description,
      deQuand: deQuand,
      aQuand: aQuand,
      backgroundColor: backgroundColor,
      recurrence: recurrence,
    );
    
  }
}
