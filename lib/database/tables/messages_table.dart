import 'package:sqflite/sqflite.dart';

import '../../modeles/messages_model.dart';
import '../messages_database.dart';

class MessageTable {
  final String tableName = "messages";

  Future<void> createTable(Database db) async{
    await db.execute(
        'CREATE TABLE $tableName(_id PRIMARY KEY, type TEXT NOT NULL,msg TEXT NOT NULL);');
  }

    Future<int> insertIntoMessagesTable(MessageFromDB message) async {
    final db = await MessageDB.instance.database;
    return await db.insert(messagesTableName, message.toJson());
    
  }
}
