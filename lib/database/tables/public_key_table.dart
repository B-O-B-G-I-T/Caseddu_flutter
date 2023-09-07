import 'package:sqflite/sqflite.dart';

class PublicKeyTable {
  final String tableName = "publicKey";

  Future<void> createTable(Database db) async {
    await db.execute(
        'CREATE TABLE $tableName( converser TEXT NOT NULL,publicKey TEXT NOT NULL);');
  }
}
