import 'package:flutter/foundation.dart';
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
    {required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.images,
    required this.type,
    required this.sendOrReceived,
    required this.timestamp, 
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


  // Factory pour créer une instance de ChatMessageParams depuis une Map
  factory ChatMessageParams.fromMap(Map<String, dynamic> data) {
    
    return ChatMessageParams(
      id:data['id'] ?? '',
      sender: data['sender'] ?? '',
      receiver: data['receiver'] ?? '',
      message : data['message'] ?? '',
      images: data['images'] ?? '',
      type: data['type'] ?? 'Payload',
      sendOrReceived: data['sendOrReceived'] ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      nearbyService: data['nearbyService'], // Pour NearbyService si fourni
    );
  }

  // Méthode pour convertir l'objet en Map, utile pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'images': images,
      'type': type,
      'sendOrReceived': sendOrReceived,
      'timestamp': timestamp.toIso8601String(),
      'broadcast': broadcast,
      'nearbyService': _nearbyService, // Peut nécessiter un traitement particulier
    };
  }

}

// class EventParams {
//   final String title;
//   final String description;
//   final DateTime deQuand;
//   final DateTime aQuand;
//   final Color backgroundColor;
//   final String recurrence;

//   const EventParams({
//     required this.title,
//     required this.description,
//     required this.deQuand,
//     required this.aQuand,
//     this.backgroundColor = Colors.lightGreen,
//     this.recurrence = 'Jamais',
//   });

//   EventModel toEventModel() {
//     return EventModel(
//       title: title,
//       description: description,
//       deQuand: deQuand,
//       aQuand: aQuand,
//       backgroundColor: backgroundColor,
//       recurrence: recurrence,
//     );
    
//   }
// }


