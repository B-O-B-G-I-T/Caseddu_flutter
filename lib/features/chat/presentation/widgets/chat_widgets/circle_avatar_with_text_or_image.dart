import 'package:flutter/material.dart';
import '../../../../../core/utils/widget_utils.dart';

class CircleAvatarWithTextOrImage extends StatelessWidget {
  final String? text;
  final ImageProvider? image;
  final Color? backgroundColor; // Couleur spécifiée par l'utilisateur
  final double radius;
  final Function? customImage;

  const CircleAvatarWithTextOrImage({
    super.key,
    this.text,
    this.image,
    this.backgroundColor, // Ajout de la couleur de fond spécifiée par l'utilisateur
    this.radius = 24.0,
    this.customImage,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ??
        generateColorFromName(text ?? ''); //generateColor('jea,'); // Utilisation de la couleur spécifiée ou génération d'une couleur aléatoire
    return GestureDetector(
      onTap: () {
        if (customImage != null) {
          customImage!();
        }
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (image != null) {
      return ClipOval(
        child: Image(
          image: image!,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
        ),
      );
    } else {
      return Text(
        text != null && text!.isNotEmpty ? text![0].toUpperCase() : '',
        style: const TextStyle(color: Colors.white),
      );
    }
  }
}
