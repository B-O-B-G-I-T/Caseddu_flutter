// ignore_for_file: unnecessary_import, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' show join;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

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
  static String dateFormatter({required String timeStamp}) {
    // From timestamp to readable date and hour minutes
    DateTime dateTime = DateTime.parse(timeStamp);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    String formattedTime = DateFormat('hh:mm aa').format(dateTime);
    return "$formattedDate $formattedTime";
  }

  static String depuisQuandCeMessageEstRecu({required String timeStamp}) {
    DateTime dateTime = DateTime.parse(timeStamp);
    DateTime dateTimeNow = DateTime.now();
    Duration diff = dateTimeNow.difference(dateTime);

    int days = diff.inDays; // Le nombre de jours depuis la réception du message
    int hours = diff.inHours.remainder(24); // Le nombre d'heures restantes
    int minutes = diff.inMinutes.remainder(60); // Le nombre de minutes restantes
    if (days > 0) {
      return '$days jour${days > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours heure${hours > 1 ? 's' : ''}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return 'maintenant';
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

  static String listImagesPathToBase64Strings(String imagePaths) {
    List<String> base64Strings = [];

    for (String imagePath in imagePaths.split(',')) {
      File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        final bytes = imageFile.readAsBytesSync();
        base64Strings.add(base64Encode(bytes));
      } else {
        log( 'Image not found', name: 'Utils');
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

  static void showLimitedAccessDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accès limité'),
          content: const Text(
            'Vous avez accordé un accès limité aux photos. Cela peut restreindre certaines fonctionnalités de l\'application. Pour une expérience complète, veuillez accorder un accès complet dans les paramètres de l\'application.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ouvrir les paramètres'),
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
          title: const Text('Permission requise'),
          content: const Text(
            'Cette application a besoin d\'accès à vos photos pour fonctionner correctement. Veuillez activer les autorisations dans les paramètres de l\'application.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ouvrir les paramètres'),
              onPressed: () {
                Navigator.of(context).pop();
                // Ouvrir les paramètres de l'application
                PhotoManager.openSetting();
              },
            ),
            TextButton(
              child: const Text('Annuler'),
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
            msg: 'Image enregistrée avec succès dans la galerie ✅',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Erreur lors de l\'enregistrement de l\'image',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Gestion des erreurs
        Fluttertoast.showToast(
          msg: 'Erreur : $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      // Permission refusée
      Fluttertoast.showToast(
        msg: 'Permission refusée',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  
  // static void envoieDeMessage(
  //     {required String destinataire, required String message, context}) {
  //   var msgId = nanoid(21);

  //   var payload = Payload(msgId, Global.myName, destinataire, message,
  //       DateTime.now().toUtc().toString(), "Payload");

  //   Global.cache[msgId] = payload;
  //   //insertIntoMessageTable(payload);
  //   Provider.of<Global>(context, listen: false).sentToConversations(
  //     Msg(message, "sent", payload.timestamp, "Payload", msgId),
  //     destinataire,
  //   );
  // }

  // static void envoieDePhoto(
  //     {required String destinataire, required String chemin, context}) {
  //   var msgId = nanoid(21);
  //   File file = File(chemin);
  //   var imageTo64String = Utils.imageToBase64String(file);
  //   var payload = Payload(msgId, Global.myName, destinataire, chemin,
  //       DateTime.now().toUtc().toString(), "Image");

  //   Global.cache[msgId] = payload;
  //   //insertIntoMessageTable(payload);

  //   Provider.of<Global>(context, listen: false).sentToConversations(
  //       Msg(imageTo64String, "sent", payload.timestamp, "Image", msgId),
  //       destinataire,
  //       isImage: chemin);
  // }
}
