import 'dart:convert';
import 'package:flutter_application_1/core/params/params.dart';
import 'package:flutter_application_1/database/messages_database.dart';
import 'package:flutter_application_1/features/chat/data/models/chat_conversation_model.dart';
import 'package:flutter_application_1/features/chat/data/models/chat_message_model.dart';
import 'package:flutter_application_1/global/payload.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/firebase_exceptions.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheChat({required ChatMessageModel? chatToCache});
  Future<void> enregistreDansLesConversations({required ChatMessageParams chatMessageParams});
}

const cachedChat = 'CACHED_TEMPLATE';

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;
  static Map<String, dynamic> cache = {};
  //static final GlobalKey<ScaffoldState> scaffoldKey =
  //   GlobalKey<ScaffoldState>();
  Map<String, Map<String, ChatMessageModel>> conversations = {
    'userTest1': {
      'message1': ChatMessageModel(
        message: 'Bonjour',
        sendOrReceived: 'sent',
        timeStamp: DateTime.now().toString(),
        typeMessage: 'Payload',
        id: 'id1',
      ),
      'message2': ChatMessageModel(
          message: 'Comment ça va ?', sendOrReceived: 'received', timeStamp: DateTime.now().toString(), typeMessage: 'Payload', id: 'id2'),
    },
    'userTest2': {
      'message1': ChatMessageModel(message: 'Salut', sendOrReceived: 'sent', timeStamp: DateTime.now().toString(), typeMessage: 'Payload', id: 'id3'),
      'message2': ChatMessageModel(
          message: 'Quoi de neuf ?', sendOrReceived: 'received', timeStamp: DateTime.now().toString(), typeMessage: 'Payload', id: 'id4'),
    },
  };

  ChatLocalDataSourceImpl({required this.sharedPreferences});


  @override
  Future<void> cacheChat({required ChatMessageModel? chatToCache}) async {
    if (chatToCache != null) {
      sharedPreferences.setString(
        cachedChat,
        json.encode(
          chatToCache.toJson(),
        ),
      );
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> enregistreDansLesConversations({required ChatMessageParams chatMessageParams}) async {
    // if (conversations[converser] == null) {
    //   conversations[converser] = {};
    // }
    var dernierEnCache = cache.entries.last;
// ajout en cache dans le global
    ChatMessageModel msglocal = ChatMessageModel(
        message: chatMessageParams.message,
        sendOrReceived: chatMessageParams.sendOrReceived,
        timeStamp: chatMessageParams.timestamp,
        typeMessage: chatMessageParams.type,
        id: chatMessageParams.id);

    if (dernierEnCache.value.runtimeType == Payload) {
      if (chatMessageParams.type == 'Image') {
        //if (addToTable) {
          insertIntoConversationsTable(msglocal, chatMessageParams.sender);
        //}
      } else {
        conversations[chatMessageParams.sender]![chatMessageParams.id] = msglocal;
        //if (addToTable) {
          insertIntoConversationsTable(msglocal, chatMessageParams.sender);
        //}
      }
    }
  }

  // Inserting message to the conversation table in the database
  void insertIntoConversationsTable(ChatMessageModel msg, String converser) {
    MessageDB.instance.insertIntoConversationsTable2(ChatConversationModel(
        sendOrReceived: msg.sendOrReceived,
        message: msg.message,
        timeStamp: msg.timeStamp,
        typeMessage: msg.typeMessage,
        converser: converser,
        id: msg.id));
  }
}
