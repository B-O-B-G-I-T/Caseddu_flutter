import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../chat/presentation/widgets/chat_widgets/circle_avatar_with_text_or_image.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({super.key, this.ontap, this.image});
  final Function? ontap;
  final String? image;
  @override
  Widget build(BuildContext context) {
    return // Image de profil ou texte
                Center(
                  child: CircleAvatarWithTextOrImage(
                    text: FirebaseAuth.instance.currentUser?.displayName ?? '',
                    radius: 50,
                    customImage: ontap,
                    image: image,
                  ),
                );
  }
}