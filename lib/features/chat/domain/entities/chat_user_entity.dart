import '../../data/models/chat_message_model.dart';

class UserEntity {
  final String id;
  final String name;
  ChatMessageModel? dernierMessage;

  UserEntity({
    required this.id,
    required this.name,
    this.dernierMessage,
  });
}
