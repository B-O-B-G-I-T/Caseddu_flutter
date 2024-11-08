import 'package:caseddu/features/chat/data/models/chat_message_model.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class UserModel extends UserEntity{

  UserModel( {required super.id, required super.name, super.dernierMessage
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      dernierMessage: json['dernierMessage'] != null ? ChatMessageModel.fromJson(json: json['dernierMessage']) : null,
    );
  }

  Device toDevice() {
    return Device(id, name, 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
