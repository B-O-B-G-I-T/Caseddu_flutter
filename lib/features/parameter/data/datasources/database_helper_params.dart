import 'package:sqflite/sqflite.dart';
import '../../../../dataBase/base_donnees_general.dart';

class DatabaseHelperParams {

  Future<String?> getUserDetail() async {
    final db = await BaseDonneesGeneral.database;

    final List<Map<String, dynamic>> maps = await db.query('user');
    if (maps.isNotEmpty) {
      return maps.first['description'];
    } else {
      return null;
    }

  }

Future<void> insertOrUpdateUserDetail(String? description) async {
  final db = await BaseDonneesGeneral.database;
  await db.insert(
    'user',
    {'id': 1, 'description': description}, // Utilisez un ID fixe
    conflictAlgorithm: ConflictAlgorithm.replace, // Remplace l'entrée existante
  );
}
}
