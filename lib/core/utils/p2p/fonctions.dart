// ignore_for_file: unnecessary_import, depend_on_referenced_packages, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' show join;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Utils {
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    final time = DateFormat.Hm().format(dateTime);
    return '$date $time';
  }

  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    return date;
  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime);
    return time;
  }

// Function to format the date in viewable form
  static String dateFormatter({required String timeStamp, BuildContext? context, String? locale}) {
    // Si la locale n'est pas fournie, on utilise celle du contexte (si le contexte est non nul)
    locale ??= context != null ? Localizations.localeOf(context).toString() : 'en_US'; // Valeur par défaut si pas de contexte

    DateTime dateTime = DateTime.parse(timeStamp);

    // Créez un format de date en fonction de la locale
    String formattedTime;

    if (locale == 'fr') {
      formattedTime = DateFormat('HH:mm', locale).format(dateTime); // Format français 24h
    } else if (locale == 'en') {
      formattedTime = DateFormat('hh:mm a', locale).format(dateTime); // Format anglais AM/PM
    } else {
      formattedTime = DateFormat('hh:mm a', locale).format(dateTime); // Format anglais AM/PM
    }

    return formattedTime;
  }

  static String depuisQuandCeMessageEstRecu({required String timeStamp, required BuildContext context}) {
    DateTime dateTime = DateTime.parse(timeStamp);
    DateTime dateTimeNow = DateTime.now();
    Duration diff = dateTimeNow.difference(dateTime);

    int days = diff.inDays; // Le nombre de jours depuis la réception du message
    int hours = diff.inHours.remainder(24); // Le nombre d'heures restantes
    int minutes = diff.inMinutes.remainder(60); // Le nombre de minutes restantes
    if (days > 0) {
      return AppLocalizations.of(context)!.nDay(days);
    } else if (hours > 0) {
      return AppLocalizations.of(context)!.nHour(hours);
    } else if (minutes > 0) {
      return AppLocalizations.of(context)!.nMinutes(minutes);
    } else {
      return AppLocalizations.of(context)!.now;
    }
  }

  static List<T> runFilter<T>(String enteredKeyword, List<T> listeAFiltre, String Function(T) selector) {
    List<T> results = [];
    if (enteredKeyword.isEmpty) {
      results = listeAFiltre;
    } else {
      results = listeAFiltre.where((item) => selector(item).toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }
    return results;
  }

  static String imageToBase64String(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  static Future<String> convertFilePathToString(String filePath) async {
    // Créer un objet File en utilisant le chemin
    final file = File(filePath);

    // Lire le fichier et le convertir en Uint8List (asynchrone)
    Uint8List bytes = await file.readAsBytes();

    // Encoder les données en base64 pour l'envoi
    String base64Image = base64Encode(bytes);
    // Retourner les données du fichier sous forme de Uint8List
    return base64Image;
  }

  static String listImagesPathToBase64Strings(String imagePaths) {
    List<String> base64Strings = [];

    for (String imagePath in imagePaths.split(',')) {
      File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        final bytes = imageFile.readAsBytesSync();
        base64Strings.add(base64Encode(bytes));
      } else {
        log('Image not found', name: 'Utils');
      }
    }
    return base64Strings.join(',');
  }

  static Future<File> base64StringToImage(String base64String) async {
    final bytes = base64Decode(base64String);
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    String cheminVersImage = join(
      (await getApplicationDocumentsDirectory()).path,
      '$uniqueId.jpg',
    );
    File imageFile = File(cheminVersImage);
    imageFile.writeAsBytesSync(bytes);
    return imageFile;
  }

  static Future<List<String>> base64StringToListImage(String? base64String) async {
    if (base64String != null && base64String.isNotEmpty) {
      final List<String> base64Strings = base64String.split(',');
      final List<String> imageFiles = [];

      for (String base64Str in base64Strings) {
        final bytes = base64Decode(base64Str);
        final uniqueId = DateTime.now().millisecondsSinceEpoch;
        String cheminVersImage = join(
          (await getApplicationDocumentsDirectory()).path,
          '$uniqueId.jpg',
        );
        debugPrint(cheminVersImage);
        File imageFile = File(cheminVersImage);
        await imageFile.writeAsBytes(bytes);
        imageFiles.add(imageFile.path);
      }

      // Vous pouvez retourner la liste de fichiers d'images si nécessaire
      return imageFiles;
    } else {
      return [];
    }

    // Si vous voulez retourner un seul fichier d'image, vous pouvez le faire comme ceci
    // return imageFiles.isNotEmpty ? imageFiles.first : null;
  }

  static String imagesEncode(String image) {
    return image.substring(100, 200);
  }

  /// Fonction pour compresser une image
  static Future<XFile?> compressImage(File file) async {
    try {
      final String targetPath = file.path.replaceFirst(
        RegExp(r'\.(\w+)$'),
        '_compressed.jpg',
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, // Chemin source
        targetPath, // Chemin cible
        quality: 5, // Qualité de compression (1 à 100)
        minWidth: 800, // Largeur minimale
        minHeight: 800, // Hauteur minimale

        format: CompressFormat.jpeg, // Format de compression
      );

      return compressedFile;
    } catch (e) {
      print("Error during image compression: $e");
      return null;
    }
  }

  static void showLimitedAccessDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.limited_access),
          content: Text(
            AppLocalizations.of(context)!.limited_access,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.open_parameters),
              onPressed: () {
                Navigator.of(context).pop();
                PhotoManager.openSetting();
              },
            ),
          ],
        );
      },
    );
  }

  static void showPermissionDeniedDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.permission_required),
          content: Text(AppLocalizations.of(context)!.permission_required),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.open_parameters),
              onPressed: () {
                Navigator.of(context).pop();
                // Ouvrir les paramètres de l'application
                PhotoManager.openSetting();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Fonction pour télécharger l'image et l'enregistrer dans la galerie
  static Future<void> saveImageToGallery(String imageUrl, BuildContext context) async {
    // Demande des permissions pour accéder à la galerie
    final permissionStatus = await PhotoManager.requestPermissionExtend();

    if (permissionStatus.isAuth || permissionStatus.hasAccess) {
      try {
        // Chargement de l'image depuis les assets
        final ByteData imageData = await rootBundle.load(imageUrl);
        final Uint8List bytes = imageData.buffer.asUint8List();

        // Enregistrement de l'image dans la galerie
        final assetEntity = await PhotoManager.editor.saveImage(bytes, filename: imageUrl);

        if (assetEntity != null) {
          // Affichage d'un message de succès avec Fluttertoast
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.image_successfully_saved_to_gallery,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.error_while_saving_the_image,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Gestion des erreurs
        Fluttertoast.showToast(
          msg: 'Error : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      // Permission refusée
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.permission_denied,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
