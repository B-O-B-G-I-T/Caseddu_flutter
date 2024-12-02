import 'package:flutter/material.dart';
import '../../../../../core/utils/p2p/fonctions.dart';
import '../../../../../core/utils/p2p/circle_avatar_with_text_or_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListTilePourUtilisateurConnu extends StatelessWidget {
  final String deviceName;
  final String message;
  final String timestamp;
  final String typeMessage;
  final VoidCallback onTap;

  const ListTilePourUtilisateurConnu({
    super.key,
    required this.deviceName,
    required this.message,
    required this.timestamp,
    required this.typeMessage,
    required this.onTap,
  });

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
          typeMessage == "Payload"
              ? Text(message)
              : typeMessage == "DELETE"
                  ? Text(AppLocalizations.of(context)!.message_deleted)
                  : const Icon(Icons.image),
          timestamp != "" ? Text(" - ${Utils.depuisQuandCeMessageEstRecu(timeStamp: timestamp, context: context)}") : const SizedBox(),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
      onTap: onTap,
    );
  }
}
