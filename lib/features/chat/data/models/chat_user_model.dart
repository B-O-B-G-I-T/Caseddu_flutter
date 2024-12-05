import 'package:caseddu/features/chat/data/models/chat_message_model.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import '../../../../core/params/params.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.name, super.dernierMessage, super.pathImageProfile, super.startEncodeImage});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      dernierMessage: json['dernierMessage'] != null ? ChatMessageModel.fromJson(json: json['dernierMessage']) : null,
      pathImageProfile: json['pathImageProfile'] ?? '',
      startEncodeImage: json['startEncodeImage'] ?? '',
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

  factory UserModel.fromUserParams(UserParams params) {
    return UserModel(
      id: params.id,
      name: params.name,
      dernierMessage: params.dernierMessage,
      pathImageProfile: params.pathImageProfile,
      startEncodeImage: params.startEncodeImage,
    );
  }
}
