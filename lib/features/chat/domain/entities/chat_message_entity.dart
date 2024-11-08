import '../../../../core/params/params.dart';

class ChatMessageEntity {
  final String id;
  final String sender;
  final String receiver;
  final DateTime timestamp;
  final String message;
  String images;
  final String type;
  int ack;

  ChatMessageEntity({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.message,
    required this.images,
    required this.type,
    required this.ack,
  });

  set setImage(String newImages) {
    newImages = images;
  }

  ChatMessageParams toParamsAKC() {
    return ChatMessageParams(
      id: id,
      sender: sender,
      receiver: receiver,
      timestamp: timestamp,
      message: message,
      images: images,
      type: type,
      sendOrReceived: 'Send',
      ack: 1,
    );
  }

  ChatMessageParams toParamsDelete() {
    return ChatMessageParams(
      id: id,
      sender: sender,
      receiver: receiver,
      timestamp: timestamp,
      message: "DELETE ",
      images: "",
      type: "DELETE",
      sendOrReceived: 'Send',
      ack: 1,
    );
  }
}
