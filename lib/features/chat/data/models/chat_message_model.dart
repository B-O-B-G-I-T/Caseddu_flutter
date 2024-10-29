import '../../../../core/params/params.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.id,
    required super.sender,
    required super.receiver,
    required super.timestamp,
    required super.message,
    required super.images,
    required super.type,
    required super.ack,
  });

  toJson() => {
        'id': id,
        'sender': sender,
        'receiver': receiver,
        'timestamp': timestamp.toString(),
        'message': message,
        'images': images,
        'type': type,
        'ack': ack,
      };
  @override
  String toString() => {
        'sender': sender,
        'receiver': receiver,
        'timestamp': timestamp,
        'message': message,
        'images': images,
        'type': type,
        'ack': ack, 
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
      ack: json['ack'],
    );

    return message;
  }
  ChatMessageParams toChatMessageParams() {
    final ChatMessageParams tampon = ChatMessageParams(
      id: id,
      sender: sender,
      receiver: receiver,
      message: message,
      images: images,
      type: type,
      timestamp: timestamp,
      sendOrReceived: 'Received',
      ack: 1,
    );

    return tampon;
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      id: id,
      sender: sender,
      receiver: receiver,
      timestamp: timestamp,
      message: message,
      images: images,
      type: type,
      ack: ack,
    );
  }
}
