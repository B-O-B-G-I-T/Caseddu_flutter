import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/p2p/circle_avatar_with_text_or_image.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({super.key, this.ontap, this.image, this.radius = 50});
  final Function? ontap;
  final String? image;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return // Image de profil ou texte
        Center(
      child: CircleAvatarWithTextOrImage(
        text: FirebaseAuth.instance.currentUser?.displayName ?? '',
        radius: radius,
        customImage: ontap,
        image: image,
      ),
    );
  }
}
