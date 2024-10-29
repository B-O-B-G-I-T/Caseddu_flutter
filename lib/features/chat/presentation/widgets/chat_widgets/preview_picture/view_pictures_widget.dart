import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget viewPicturesWidget({required BuildContext context, required List<String> pictures}) {
  return Wrap(
    spacing: 4.0, // Espacement horizontal entre les images
    runSpacing: 4.0, // Espacement vertical entre les images
    children: pictures.map((picture) {
      return GestureDetector(
        onTap: () {
          // Navigue vers l'affichage plein écran de l'image
          context.push(
            '/fullScreenImage/:filePath',
            extra: picture,
          );
        },
        child: SizedBox(
          width: 100, // Largeur maximale pour chaque image
          height: 200, // Hauteur maximale pour chaque image
          child: FutureBuilder(
            future: precacheImage(AssetImage(picture), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Affiche un overlay pendant le chargement de l'image
                return Container(
                  color: Colors.black26,
                  width: 100,
                  height: 200,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else {
                // Affiche l'image une fois qu'elle est chargée
                return FittedBox(
                  fit: BoxFit.contain, // Ajuste l'image pour remplir le conteneur tout en conservant les proportions
                  child: Image.asset(picture),
                );
              }
            },
          ),
        ),
      );
    }).toList(),
  );
}
