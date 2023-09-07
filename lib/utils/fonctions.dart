import 'package:intl/intl.dart';

class Utils {
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    final time = DateFormat.Hm().format(dateTime);
    return '$date $time';
  }

  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    return '$date';
  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime);
    return '$time';
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
}
