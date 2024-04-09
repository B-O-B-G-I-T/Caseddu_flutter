import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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
    int minutes =
        diff.inMinutes.remainder(60); // Le nombre de minutes restantes
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

  static List<T> runFilter<T>(String enteredKeyword, List<T> listeAFiltre,
      String Function(T) selector) {
    List<T> results = [];
    if (enteredKeyword.isEmpty) {
      results = listeAFiltre;
    } else {
      results = listeAFiltre
          .where((item) => selector(item)
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    return results;
  }

  static String imageToBase64String(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
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
