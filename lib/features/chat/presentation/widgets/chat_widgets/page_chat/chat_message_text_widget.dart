import 'package:flutter/material.dart';

import '../../../../domain/entities/chat_message_entity.dart';
import '../preview_picture/all_preview_picture_widget.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessageEntity message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.images.isNotEmpty) {
      return AllPreviewPictureChatWidget(messageList: message);
    } else {
      return Text(
        message.message,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: message.ack == 1 ? Colors.black : Colors.grey,
          fontSize: 14,
        ),
      );
    }
  }
}
