import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BaseDonneesGeneral {
  static final BaseDonneesGeneral _instance = BaseDonneesGeneral.internal();
  factory BaseDonneesGeneral() => _instance;

  static late Database _database;

  BaseDonneesGeneral.internal();

  static Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'messsageTables.db');
    print(path);
    // Delete the database if it already exists
    // await deleteDatabase(path);

    // Open/create the database at a given path
    Database db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  static Future<Database> get database async {
    //if (_database != null) return _database;
    _database = await initDb();
    return _database;
  }

// ------------------------ CREATE TABLES ------------------------
  static void _onCreate(Database db, int version) async {
    // Create your tables here
    await db.execute('''
      CREATE TABLE users (
          id TEXT PRIMARY KEY,
          name TEXT
        )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
          id TEXT PRIMARY KEY,
          sender TEXT,
          receiver TEXT,
          timestamp TEXT,
          message TEXT,
          images TEXT,
          type TEXT,
          FOREIGN KEY (receiver) REFERENCES users(id)
        )
    ''');

    await db.execute('''
        CREATE TABLE evenements (
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          deQuand TEXT,
          aQuand TEXT,
          backgroundColor INTEGER,
          recurrence TEXT
        )
      ''');

    //   await db.execute('''
    //   CREATE TABLE conversations_messages (
    //     id TEXT PRIMARY KEY,
    //     title TEXT,
    //     unreadCount INTEGER,
    //     lastMessageId TEXT,
    //     FOREIGN KEY (lastMessageId) REFERENCES chat_messages(id)
    //   )
    // ''');

    // List<ChatMessageModel> messages = [];
    // ChatMessageModel lastMessage;
  }
}
