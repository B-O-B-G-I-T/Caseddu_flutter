// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../models/parameter_model.dart';
import 'package:path/path.dart' as path;

abstract class ParametreLocalDataSource {
  Future<void> cacheParametre({required ParameterModel? parametreToCache});
  Future<ParameterModel> getLastParametre();
  Future<String> saveImageProfile(AssetEntity image);
  Future<String?> getSavedProfileImage();
}

const cachedParametre = 'CACHED_TEMPLATE';

class ParametreLocalDataSourceImpl implements ParametreLocalDataSource {
  final SharedPreferences sharedPreferences;

  ParametreLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ParameterModel> getLastParametre() {
    final jsonString = sharedPreferences.getString(cachedParametre);

    if (jsonString != null) {
      return Future.value(ParameterModel.fromJson(json: json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheParametre({required ParameterModel? parametreToCache}) async {
    if (parametreToCache != null) {
      sharedPreferences.setString(
        cachedParametre,
        json.encode(
          parametreToCache.toJson(),
        ),
      );
    } else {
      throw CacheException();
    }
  }

  @override
  Future<String> saveImageProfile(AssetEntity image) async {
    try {
      // Obtenir le fichier temporaire correspondant à l'AssetEntity
      final File? originalFile = await image.file;

      if (originalFile == null) {
        throw Exception('L\'image originale est introuvable.');
      }

      // Obtenir le répertoire d'application (local)
      final Directory appDirectory = await getApplicationDocumentsDirectory();

      // Construire le chemin du dossier cible pour stocker l'image
      final String profileImageDirPath = path.join(appDirectory.path, "profileImage");
      final Directory profileImageDir = Directory(profileImageDirPath);

      // Créer le dossier s'il n'existe pas
      if (!profileImageDir.existsSync()) {
        await profileImageDir.create(recursive: true);
      }

      // Supprimer les fichiers existants dans le dossier
      for (final FileSystemEntity entity in profileImageDir.listSync()) {
        if (entity is File) {
          await entity.delete();
        }
      }

      // Construire le chemin cible pour enregistrer la nouvelle image
      final String newFilePath = path.join(profileImageDirPath, path.basename(originalFile.path));

      // Copier le fichier original dans le répertoire cible
      final File savedFile = await originalFile.copy(newFilePath);

      // Retourner le chemin du fichier sauvegardé
      return savedFile.path;
    } on Exception catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'image : ${e.toString()}');
    }
  }

  @override
  Future<String?> getSavedProfileImage() async {
    try {
      // Obtenir le répertoire d'application
      final Directory appDirectory = await getApplicationDocumentsDirectory();

      // Construire le chemin du dossier contenant l'image
      final String profileImagePath = path.join(appDirectory.path, "profileImage");
      final Directory profileImageDir = Directory(profileImagePath);

      // Vérifier si le dossier existe
      if (!profileImageDir.existsSync()) {
        return null; // Pas de dossier, donc pas d'image
      }

      // Lister les fichiers dans le dossier
      final List<FileSystemEntity> files = profileImageDir.listSync();

      // Rechercher le premier fichier trouvé
      for (final FileSystemEntity entity in files) {
        if (entity is File) {
          return entity.path; // Retourner le fichier trouvé
        }
      }

      return null; // Aucun fichier dans le dossier
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'image de profil : ${e.toString()}');
    }
  }
}
