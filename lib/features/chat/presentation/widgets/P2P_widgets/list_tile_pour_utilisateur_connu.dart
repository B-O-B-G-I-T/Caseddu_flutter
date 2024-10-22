import 'package:flutter/material.dart';

import '../../../../../core/utils/p2p/fonctions.dart';
import '../chat_widgets/circle_avatar.dart';

class ListTilePourUtilisateurConnu extends StatelessWidget {
  final String deviceName;
  final String message;
  final String timestamp;
  final String typeMessage;
  final VoidCallback onTap;

  const ListTilePourUtilisateurConnu({
    Key? key,
    required this.deviceName,
    required this.message,
    required this.timestamp,
    required this.typeMessage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatarWithTextOrImage(
        text: deviceName.isNotEmpty ? deviceName[0].toUpperCase() : "?", // Utilisez le premier caractère du nom comme texte
        radius: 24.0, // Rayon du cercle
      ),
      title: Text(
        deviceName.isNotEmpty ? deviceName : "?",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      subtitle: Row(
        children: [
          typeMessage == "Payload" ? Text(message.isNotEmpty ? message : "Pas d'ancien message") : const Icon(Icons.image),
          const Text(" - "),
          Text(Utils.depuisQuandCeMessageEstRecu(timeStamp: timestamp)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
      onTap: onTap,
    );
  }
}
