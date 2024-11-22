import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../core/utils/p2p/fonctions.dart';

@override
Widget laBarre(bool messageDeReceptionOuEnvoi) {
  return Row(
    children: [
      Container(
        width: 2,
        height: double.infinity,
        color: messageDeReceptionOuEnvoi == true ? Colors.red : Colors.blue,
      ),
      const SizedBox(
        width: 5,
      )
    ],
  );
}

@override
Widget receptionOuEnvoi(
  String messageDeReceptionOuEnvoi,
  BuildContext context,
  bool isMe,
) {
  return Text(
    isMe == true ? messageDeReceptionOuEnvoi : AppLocalizations.of(context)!.me,
    style: TextStyle(
      color: isMe == true ? Colors.red : Colors.blue,
    ),
  );
}

@override
Widget dateDuMessage(String dateDeLaReception, BuildContext context) {
  return Text(
    Utils.dateFormatter(
      timeStamp: dateDeLaReception,
      context: context,
    ),
    style: const TextStyle(fontSize: 10),
  );
}
