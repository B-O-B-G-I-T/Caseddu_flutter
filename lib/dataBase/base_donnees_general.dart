// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
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

    debugPrint(path);
    // Delete the database if it already exists
    // deleteDatabase(path);

    // Open/create the database at a given path
    Database db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }


  static Future<Database> get database async {
    //if (_database.isOpen) return _database;
    _database = await initDb();
    return _database;
  }

// ------------------------ CREATE TABLES ------------------------
  static void _onCreate(Database db, int version) async {
    // Create your tables here
    await db.execute('''
      CREATE TABLE users (
          id TEXT PRIMARY KEY,
          name TEXT,
          pathImageProfile TEXT,
          myLastStartEncodeImage TEXT
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
          ack BOOLEAN DEFAULT 0,
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
  }

  // ------------------------ UPGRADE DATABASE ------------------------
  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Vérifiez si une mise à jour est nécessaire
      await db.execute('''
        ALTER TABLE chat_messages ADD COLUMN ACK BOOLEAN DEFAULT 0
      ''');
    }
  }
}
