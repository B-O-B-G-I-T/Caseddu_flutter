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
  });

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
  ChatMessageParams toChatMessageParams({required ChatMessageModel chatMessageModel}) {
    var message = ChatMessageParams(
      id: chatMessageModel.id,
      sender: chatMessageModel.sender,
      receiver: chatMessageModel.receiver,
      message: chatMessageModel.message,
      images: chatMessageModel.images,
      type: chatMessageModel.type,
      timestamp: chatMessageModel.timestamp,
      sendOrReceived: '',
    );

    return message;
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
    );
  }
}
