import 'package:sqflite/sqflite.dart';

class ConversationsTable {
  final String tableName = "conversations";

  Future<void> createTable(Database db) async{
    await db.execute(
        'CREATE TABLE $tableName(_id PRIMARY KEY, converser TEXT NOT NULL,type TEXT NOT NULL,msg TEXT NOT NULL,timestamp TEXT NOT NULL, ack TEXT NOT NULL);');

  }
}
