import '../../data/models/chat_message_model.dart';

class UserEntity {
  final String id;
  final String name;
  ChatMessageModel? dernierMessage;
  final String? pathImageProfile;
  final String? myLastStartEncodeImage;

  UserEntity(  {
    required this.id,
    required this.name,
    this.dernierMessage,
    this.pathImageProfile,
    this.myLastStartEncodeImage,
  });
}
