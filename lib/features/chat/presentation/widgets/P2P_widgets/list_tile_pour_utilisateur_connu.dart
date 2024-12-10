import 'package:flutter/material.dart';
import '../../../../../core/utils/p2p/fonctions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../domain/entities/chat_user_entity.dart';
import '../chat_widgets/page_chat/chat_circle_avatar.dart';

class ListTilePourUtilisateurConnu extends StatelessWidget {
  final String deviceName;
  final String message;
  final String timestamp;
  final String typeMessage;
  final UserEntity userEntity;
  final VoidCallback onTap;

  const ListTilePourUtilisateurConnu({
    super.key,
    required this.deviceName,
    required this.message,
    required this.timestamp,
    required this.typeMessage,
    required this.onTap,
    required this.userEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: ChatCircleAvatar(
              text: deviceName,
              context: context,
            ),
            title: Text(
              deviceName.isNotEmpty ? deviceName : "?",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Row(
              children: [
                typeMessage == "payload"
                    ? Text(message)
                    : typeMessage == "DELETE"
                        ? Text(AppLocalizations.of(context)!.message_deleted)
                        : const Icon(Icons.image),
                timestamp != "" ? Text(" - ${Utils.depuisQuandCeMessageEstRecu(timeStamp: timestamp, context: context)}") : const SizedBox(),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: onTap,
          ),
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
