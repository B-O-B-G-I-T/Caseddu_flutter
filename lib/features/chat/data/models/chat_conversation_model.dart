import 'package:flutter_application_1/core/constants/constants.dart';
import 'package:flutter_application_1/features/chat/domain/entities/chat_conversation_entity.dart';

class ChatConversationModel extends ChatConversationEntity {
  ChatConversationModel({required String id, required String sendOrReceived, required String message, required String converser, required String timeStamp, required String typeMessage}) : super(sendOrReceived: sendOrReceived, message: message, id: id, converser: converser, timeStamp: timeStamp, typeMessage: typeMessage);

  factory ChatConversationModel.fromJson({required Map<String, dynamic> json}) {
    return ChatConversationModel(
      id: json['kChatId'], 
      sendOrReceived: json['kChatSendOrReceived'], 
      message: json['kChatMessage'], 
      converser: json['kChatConverser'], 
      timeStamp: json['kChatTimeStamp'], 
      typeMessage: json['kChatTypeMessage']);
  }

  Map<String, dynamic> toJson() {
    return {
      kChatId: id,
      kChatSendOrReceived: sendOrReceived,
      kChatMessage: message,
      kChatConverser : converser,
      kChatTimeStamp: timeStamp,
      kChatTypeMessage: typeMessage,
      
    };
  }
  //  Map<String, dynamic> toJson() => {ConversationTableFields.id: id, ConversationTableFields.type: sendOrReceived, ConversationTableFields.msg: msg, ConversationTableFields.converser: converser, ConversationTableFields.ack: typeMsg, ConversationTableFields.timestamp: timestamp};

  // static ConversationFromDB fromJson(Map<String, Object?> json) => ConversationFromDB(json[ConversationTableFields.id].toString(), json[ConversationTableFields.type].toString(), json[ConversationTableFields.msg].toString(), json[ConversationTableFields.timestamp].toString(), json[ConversationTableFields.ack].toString(), json[ConversationTableFields.converser].toString());
}
