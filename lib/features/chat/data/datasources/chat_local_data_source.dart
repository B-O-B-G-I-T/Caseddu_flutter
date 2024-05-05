import 'dart:ffi';

import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';
import 'local_database/dataBaseHelper.dart';

abstract class ChatLocalDataSource {
  Future<void> insertMessage({required ChatMessageModel chatMessageModel, required bool isSender});
  Future<List<ChatMessageModel>> getAllMessages();
  Future<List<ChatMessageModel>> getConversation(String senderName, String receiverName);
  Future<List<UserModel>> getAllConversation();
  Future<void> deleteConversation(UserEntity userEntity);
}

const cachedChat = 'CACHED_TEMPLATE';

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;

  ChatLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> insertMessage({required ChatMessageModel chatMessageModel, required bool isSender}) async {
    // final UserModel receiver = await getUserName(chatMessageModel.receiver);
    // final UserModel sender = await getUserName(chatMessageModel.sender);
    // chatMessageModel.setReceiver = receiver.id;
    // chatMessageModel.setSender = sender.id;

    if (chatMessageModel.type == 'Image') {
      insertIntoMessagesTable(chatMessageModel, isSender);
    } else {
      insertIntoMessagesTable(chatMessageModel, isSender);
    }
  }

// ------------------------------ FOR USER ------------------------------
  Future<UserModel> getUserName(String name) async {
    final dbHelper = DatabaseHelper();
    final UserModel? user = await dbHelper.getUserByName(name);
    final UserModel userModel;

    if (user == null) {
      final String userId = nanoid(21);
      userModel = UserModel(id: userId, name: name);
      dbHelper.insertUser(userModel);
    } else {
      userModel = user;
      print('User already exists');
    }

    return userModel;
  }

// ------------------------------ FOR MESSAGES ------------------------------
  Future<void> insertIntoMessagesTable(ChatMessageModel msg, bool isSender) async {
    final dbHelper = DatabaseHelper();

    // Insérer le message dans la table des messages de chat et obtenir l'identifiant du message
    await dbHelper.insertChatMessage(msg, isSender);
  }

  @override
  Future<List<ChatMessageModel>> getAllMessages() async {
    final dbHelper = DatabaseHelper();
    List<ChatMessageModel> allChatMessages = await dbHelper.getAllChatMessages();

    // for (var message in allChatMessages) {
    //   print('Sender: ${message.sender}, Receiver: ${message.receiver}, Timestamp: ${message.timestamp}, Message: ${message.message}, Type: ${message.type}');
    // }

    return allChatMessages;
  }

  @override
  Future<List<ChatMessageModel>> getConversation(String senderName, String receiverName) async {
    final dbHelper = DatabaseHelper();
    // j'ai essaier de passer en id mais pas trop d'interet au final
    //final UserModel senderId = await getUserName(senderName);
    //final UserModel receiverId = await getUserName(receiverName);
    //List<ChatMessageModel>? allChatMessages = await dbHelper.getConversation(senderId.id, receiverId.id);
    List<ChatMessageModel>? allChatMessages = await dbHelper.getConversation(senderName, receiverName);

    // for (var message in allChatMessages) {
    //   print('Sender: ${message.sender}, Receiver: ${message.receiver}, Timestamp: ${message.timestamp}, Message: ${message.message}, Type: ${message.type}');
    // }

    return allChatMessages!;
  }

  @override
  Future<List<UserModel>> getAllConversation() async {
    final dbHelper = DatabaseHelper();

    List<UserModel>? allChatMessages = await dbHelper.getAllConversation();
    if (allChatMessages != null) {
      // for (var message in allChatMessages) {
      //   print('Sender: ${message.sender}, Receiver: ${message.receiver}, Timestamp: ${message.timestamp}, Message: ${message.message}, Type: ${message.type}');
      // }
      // Parcourir la liste et ajouter f à chaque élément
      for (var user in allChatMessages) {
        ChatMessageModel? dernierMessage = await dbHelper.getLastMessage(user.id);
        user.dernierMessage = dernierMessage;
      }

      return allChatMessages;
    } else {
      return [];
    }
  }

  @override
  Future<void> deleteConversation(UserEntity userEntity) async {
    final dbHelper = DatabaseHelper();
    dbHelper.deleteConversation(userEntity.id);
    dbHelper.deleteUser(userEntity.id);

  }
}
