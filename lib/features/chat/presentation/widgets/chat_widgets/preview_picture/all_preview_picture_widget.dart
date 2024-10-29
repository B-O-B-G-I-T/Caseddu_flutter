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
        Stack(
          children: [
            // Display the dark overlay only when ack == 0

            viewPicturesWidget(
              context: context,
              pictures: messageList.images.split(','),
            ),

            if (messageList.ack == 0)
              Container(
                color: Colors.black26,
                width: 100, // Ensures overlay covers full width
                height: 200, // Ensures overlay covers full height
              ),
          ],
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
