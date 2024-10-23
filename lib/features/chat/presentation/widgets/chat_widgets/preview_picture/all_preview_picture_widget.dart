import 'package:flutter/material.dart';

import '../../../../domain/entities/chat_message_entity.dart';
import 'view_pictures_widget.dart';

class AllPreviewPictureChatWidget extends StatelessWidget {
  const AllPreviewPictureChatWidget({
    super.key,
    required this.messageList,
  });

  final ChatMessageEntity messageList;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        viewPicturesWidget(
          context: context,
          pictures: messageList.images.split(','),
        ),
        messageList.message != ''
            ? Text(
                messageList.message,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              )
            : const SizedBox(),
      ],
    );
  }
}