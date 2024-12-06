import 'package:caseddu/features/chat/domain/entities/chat_message_entity.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/params/params.dart';
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';
import 'local_database/data_base_helper.dart';

abstract class ChatLocalDataSource {
  Future<UserModel> getUserName(UserParams userParams);
  Future<void> insertMessage({required ChatMessageModel chatMessageModel, required bool isSender});
  Future<List<ChatMessageModel>> getAllMessages();
  Future<List<ChatMessageModel>> getConversation(String senderName, String receiverName, {DateTime? beforeDate, int limit = 20});
  Future<List<UserModel>> getAllConversation();
  Future<void> deleteMessage(ChatMessageEntity chatMessageEntity);
  Future<void> deleteConversation(UserEntity userEntity);
  Future<UserModel> saveSendedImageProfile(UserParams userParams);
}

const cachedChat = 'CACHED_TEMPLATE';

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;

  ChatLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> insertMessage({required ChatMessageModel chatMessageModel, required bool isSender}) async {
    if (chatMessageModel.type == 'Image') {
      insertIntoMessagesTable(chatMessageModel, isSender);
    } else {
      insertIntoMessagesTable(chatMessageModel, isSender);
    }
  }

// ------------------------------ FOR USER ------------------------------
  @override
  Future<UserModel> getUserName(UserParams userParams) async {
    final dbHelper = DatabaseHelper();
    final UserModel? user = await dbHelper.getUserByName(userParams.name);
    final UserModel userModel;

    if (user == null) {
      final String userId = nanoid(21);
      userModel = UserModel(
          id: userId,
          name: userParams.name,
          pathImageProfile: userParams.pathImageProfile,
          myLastStartEncodeImage: userParams.myLastStartEncodeImage);
      dbHelper.insertUser(userModel);
    } else {
      userModel = user;
      debugPrint('User already exists');
    }

    return userModel;
  }

  @override
  Future<UserModel> saveSendedImageProfile(UserParams userParams) async {
    final dbHelper = DatabaseHelper();
    UserModel userModel = await dbHelper.controlUtilisateur(userParams.name);
    userModel = await dbHelper.updateUserImage(userModel, userParams.pathImageProfile, userParams.myLastStartEncodeImage);

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

    return allChatMessages;
  }

  @override
  Future<List<ChatMessageModel>> getConversation(String senderName, String receiverName, {DateTime? beforeDate, int limit = 20}) async {
    final dbHelper = DatabaseHelper();

    List<ChatMessageModel>? allChatMessages = await dbHelper.getConversation(senderName, receiverName, beforeDate: beforeDate, limit: limit);

    return allChatMessages!;
  }

  @override
  Future<List<UserModel>> getAllConversation() async {
    final dbHelper = DatabaseHelper();

    List<UserModel>? allChatMessages = await dbHelper.getAllConversation();
    if (allChatMessages != null) {
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
  Future<void> deleteMessage(ChatMessageEntity chatMessageEntity) async {
    final dbHelper = DatabaseHelper();
    dbHelper.deleteMessage(chatMessageEntity.id);
  }

  @override
  Future<void> deleteConversation(UserEntity userEntity) async {
    final dbHelper = DatabaseHelper();
    dbHelper.deleteConversation(userEntity.id);
    dbHelper.deleteUser(userEntity.id);
  }
}
