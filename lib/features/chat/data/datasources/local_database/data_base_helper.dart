// ignore_for_file: unused_field
import 'dart:async';
import 'package:caseddu/dataBase/base_donnees_general.dart';
import 'package:nanoid/nanoid.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_user_model.dart';

class DatabaseHelper {
  final BaseDonneesGeneral _baseDonnesGeneral = BaseDonneesGeneral();
// ------------------------ CHECK TABLES ------------------------
  Future<bool> isTableEmpty(String tableName) async {
    final db = await BaseDonneesGeneral.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    return count == 0;
  }

// ------------------------ USERS ------------------------
  Future<bool> isUserExists(String userId) async {
    final db = await BaseDonneesGeneral.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users WHERE id = ?', [userId]));
    if (count == null) {
      return false;
    } else {
      return count > 0;
    }
  }

  Future<UserModel?> getUserByName(String userName) async {
    final db = await BaseDonneesGeneral.database;

    final List<Map<String, dynamic>> maps = await db.query('users', where: 'name = ?', whereArgs: [userName]);
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertUser(UserModel user) async {
    final db = await BaseDonneesGeneral.database;
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel> controlUtilisateur(String nomUtilisater) async {
    UserModel? user = await getUserByName(nomUtilisater);

    if (user == null) {
      user = UserModel(id: nanoid(21), name: nomUtilisater);
      insertUser(user);
    }
    return user;
  }

  Future<void> deleteUser(String userId) async {
    final db = await BaseDonneesGeneral.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

// ------------------------ CHAT MESSAGES ------------------------
  Future<List<ChatMessageModel>> getAllChatMessages() async {
    final db = await BaseDonneesGeneral.database;
    final List<Map<String, dynamic>> maps = await db.query('chat_messages');
    return List.generate(maps.length, (index) {
      return ChatMessageModel.fromJson(json: maps[index]);
    });
  }

  Future<String> insertChatMessage(ChatMessageModel chatMessage, bool isSender) async {
    final db = await BaseDonneesGeneral.database;

    late ChatMessageModel newChat;
    //print(chatMessage.toJson());

    if (isSender) {
      UserModel user = await controlUtilisateur(chatMessage.receiver);
      newChat = ChatMessageModel(
        id: chatMessage.id,
        sender: chatMessage.sender,
        receiver: user.id,
        timestamp: chatMessage.timestamp,
        message: chatMessage.message,
        images: chatMessage.images,
        type: chatMessage.type,
        ack: chatMessage.ack,
      );
    } else {
      UserModel user = await controlUtilisateur(chatMessage.sender);
      newChat = ChatMessageModel(
        id: chatMessage.id,
        sender: user.id,
        receiver: chatMessage.receiver,
        timestamp: chatMessage.timestamp,
        message: chatMessage.message,
        images: chatMessage.images,
        type: chatMessage.type,
        ack: chatMessage.ack,
      );
    }

    final messageId = await db.insert('chat_messages', newChat.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    return messageId.toString();
  }

  Future<ChatMessageModel?> getLastMessage(String idUser) async {
    final db = await BaseDonneesGeneral.database;
    final maps = await db.query('chat_messages',
        where: 'receiver = ? or sender = ?',
        whereArgs: [
          idUser,
          idUser,
        ],
        orderBy: 'timestamp DESC',
        limit: 1);
    if (maps.isNotEmpty) {
      return ChatMessageModel.fromJson(json: maps.first);
    } else {
      return null; // Retourner null si aucune conversation n'est trouvée
    }
  }
// ------------------------ CONVERSATIONS ------------------------

  Future<List<ChatMessageModel>?> getConversation(String senderName, String receiverName, {DateTime? beforeDate, int limit = 20}) async {
    final db = await BaseDonneesGeneral.database;

    // Récupérer l'ID de l'utilisateur
    UserModel? user = await controlUtilisateur(receiverName);

    // Construire la requête SQL avec des filtres de date et de limite
    String whereClause = '((sender = ? AND receiver = ?) OR (sender = ? AND receiver = ?))';
    List<dynamic> whereArgs = [senderName, user.id, user.id, senderName];

    // Ajouter la condition pour limiter aux messages avant `beforeDate`, si elle est fournie
    if (beforeDate != null) {
      whereClause += ' AND datetime(timestamp) < datetime(?)';
      whereArgs.add(beforeDate.toIso8601String());
    }

    // Exécuter la requête avec une limite
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC', // On trie du plus récent au plus ancien
      limit: limit,
    );

    if (maps.isNotEmpty) {
      return List.generate(maps.length, (index) {
        return ChatMessageModel.fromJson(json: maps[index]);
      });
    } else {
      return null; // Retourner null si aucune conversation n'est trouvée
    }
  }

  Future<List<UserModel>?> getAllConversation() async {
    final db = await BaseDonneesGeneral.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    if (maps.isNotEmpty) {
      return List.generate(maps.length, (index) {
        return UserModel.fromJson(
          maps[index],
        );
      });
    } else {
      return null; // Retourner null si aucune conversation n'est trouvée
    }
  }

  Future<void> deleteMessage(String messsageId) async {
    final db = await BaseDonneesGeneral.database;
    await db.delete('chat_messages', where: 'id = ?', whereArgs: [messsageId]);
  }

  Future<void> deleteConversation(String userId) async {
    final db = await BaseDonneesGeneral.database;
    await db.delete('chat_messages', where: 'sender = ? OR receiver = ?', whereArgs: [userId, userId]);
  }

// ------------------------ GENERIC ------------------------
  Future<List<Map<String, dynamic>>> query(String table) async {
    Database dbClient = await BaseDonneesGeneral.database;
    return await dbClient.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
    Database dbClient = await BaseDonneesGeneral.database;
    return await dbClient.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    Database dbClient = await BaseDonneesGeneral.database;
    return await dbClient.delete(table, where: where, whereArgs: whereArgs);
  }
}
