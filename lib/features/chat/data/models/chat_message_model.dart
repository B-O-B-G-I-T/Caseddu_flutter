import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel(
      {required String sender,
      required String receiver,
      required DateTime timestamp,
      required String message,
      required String images,
      required String type,
      String? id})
      : super(sender: sender, receiver: receiver, timestamp: timestamp, message: message, images: images, type: type, id: id);

  // set setSender(String setSender) {
  //   sender = setSender;
  // }

  // set setReceiver(String newReceiver) {
  //   receiver = newReceiver;
  // }

  toJson() => {
        'id': id,
        'sender': sender,
        'receiver': receiver,
        'timestamp': timestamp.toString(),
        'message': message,
        'images': images,
        'type': type,
      };
  @override
  String toString() => {
        'sender': sender,
        'receiver': receiver,
        'timestamp': timestamp,
        'message': message,
        'images': images,
        'type': type,
      }.toString();

  factory ChatMessageModel.fromJson({required Map<String, dynamic> json}) {
    var message = ChatMessageModel(
      id: json['id'],
      sender: json['sender'],
      receiver: json['receiver'],
      message: json['message'],
      images: json['images'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );

    return message;
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      sender: sender,
      receiver: receiver,
      timestamp: timestamp,
      message: message,
      images: images,
      type: type,
    );
  }
}
