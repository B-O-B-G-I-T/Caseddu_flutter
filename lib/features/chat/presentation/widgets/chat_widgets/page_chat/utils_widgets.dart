
import 'package:flutter/material.dart';

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
  bool isMe,
) {
  return Text(
    isMe == true ? messageDeReceptionOuEnvoi : "Moi",
    style: TextStyle(
      color: isMe == true ? Colors.red : Colors.blue,
    ),
  );
}

@override
Widget dateDuMessage(String dateDeLaReception) {
  return Text(
    Utils.dateFormatter(
      timeStamp: dateDeLaReception,
    ),
    style: const TextStyle(fontSize: 10),
  );
}