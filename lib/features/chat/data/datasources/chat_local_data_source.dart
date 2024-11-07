import 'package:caseddu/features/chat/domain/entities/chat_message_entity.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';
import 'local_database/data_base_helper.dart';

abstract class ChatLocalDataSource {
  Future<void> insertMessage({required ChatMessageModel chatMessageModel, required bool isSender});
  Future<List<ChatMessageModel>> getAllMessages();
  Future<List<ChatMessageModel>> getConversation(String senderName, String receiverName);
  Future<List<UserModel>> getAllConversation();
  Future<void> deleteMessage(ChatMessageEntity chatMessageEntity);
  Future<void> deleteConversation(UserEntity userEntity);
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

    return allChatMessages;
  }

  @override
  Future<List<ChatMessageModel>> getConversation(String senderName, String receiverName) async {
    final dbHelper = DatabaseHelper();

    List<ChatMessageModel>? allChatMessages = await dbHelper.getConversation(senderName, receiverName);

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
