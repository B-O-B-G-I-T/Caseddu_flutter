import 'package:caseddu/features/calendar/data/models/event_model.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../../dataBase/base_donnees_general.dart';

class DatabaseHelperCalendar {
  final BaseDonneesGeneral _baseDonnesGeneral = BaseDonneesGeneral();
// ------------------------ CHECK TABLES ------------------------
  
  Future<void> ajoutEvenement(EventModel eventModel) async {
    final db = await _baseDonnesGeneral.database;
    await db.insert('evenements', eventModel.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
