import 'package:flutter_application_1/core/constants/constants.dart';
import 'package:flutter_application_1/features/chat/domain/entities/chat_message_entity.dart';

const String messagesTableName = 'messages';
const String conversationsTableName = 'conversations';
const String publicKeyTableName = 'publicKey';

/// Message model
class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({required String message, required String sendOrReceived, required String timeStamp, required String typeMessage, required String id,}) : 
  super(message: message, sendOrReceived: sendOrReceived, timeStamp: timeStamp, typeMessage: typeMessage, id: id);

  factory ChatMessageModel.fromJson({
    required Map<String, dynamic> json,
  }) {
    return ChatMessageModel(
      message: json['kChatMessage'],
      sendOrReceived: json['kChatSendOrReceived'],
      timeStamp: json['kChatTimestamp'],
      typeMessage: json['kChatTypeMsg'],
      id: json['kChatId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kChatMessage: message,
      kChatSendOrReceived: sendOrReceived,
      kChatTimeStamp: timeStamp,
      kChatTypeMessage: typeMessage,
      kChatId: id,
    };
  }
}

class MessageTableFields {
  static final List<String> values = [id, type, msg];
  static const String type = 'type';
  static const String msg = 'msg';
  static const String id = '_id';
}

class ConversationTableFields {
  static final List<String> values = [id, type, msg, converser, timestamp, ack];
  static const String type = 'type';
  static const String msg = 'msg';
  static const String id = '_id';
  static const String converser = 'converser';
  static const String timestamp = 'timestamp';
  static const String ack = 'ack';
}

class MessageFromDB {
  final String type;
  final String msg;
  final String id;

  MessageFromDB(this.id, this.type, this.msg);

  Map<String, Object?> toJson() => {MessageTableFields.id: id, MessageTableFields.type: type, MessageTableFields.msg: msg};

  static MessageFromDB fromJson(Map<String, Object?> json) => MessageFromDB(json[MessageTableFields.id].toString(), json[MessageTableFields.type].toString(), json[MessageTableFields.msg].toString());
}

class ConversationFromDB {
  final String sendOrReceived;
  final String msg;
  final String id;
  final String converser;
  final String timestamp;
  final String typeMsg;

  ConversationFromDB(this.id, this.sendOrReceived, this.msg, this.timestamp, this.typeMsg, this.converser);

  Map<String, Object?> toJson() => {ConversationTableFields.id: id, ConversationTableFields.type: sendOrReceived, ConversationTableFields.msg: msg, ConversationTableFields.converser: converser, ConversationTableFields.ack: typeMsg, ConversationTableFields.timestamp: timestamp};

  static ConversationFromDB fromJson(Map<String, Object?> json) => ConversationFromDB(json[ConversationTableFields.id].toString(), json[ConversationTableFields.type].toString(), json[ConversationTableFields.msg].toString(), json[ConversationTableFields.timestamp].toString(), json[ConversationTableFields.ack].toString(), json[ConversationTableFields.converser].toString());
}

class PublicKeyFields {
  static final List<String> values = [converser, publicKey];
  static const String converser = 'converser';
  static const String publicKey = 'publicKey';
}

class PublicKeyFromDB {
  final String converser;
  final String publicKey;

  PublicKeyFromDB(
    this.converser,
    this.publicKey,
  );

  Map<String, Object?> toJson() => {PublicKeyFields.publicKey: publicKey, PublicKeyFields.converser: converser};

  static PublicKeyFromDB fromJson(Map<String, Object?> json) => PublicKeyFromDB(
        json[PublicKeyFields.publicKey].toString(),
        json[PublicKeyFields.converser].toString(),
      );
}
