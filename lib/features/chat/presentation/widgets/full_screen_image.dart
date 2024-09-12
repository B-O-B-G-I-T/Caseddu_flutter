import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // Fond noir

        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // L'image prend tout l'espace disponible sauf celui des boutons
                  Positioned.fill(
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.contain, // Ajuste l'image pour remplir le conteneur tout en conservant les proportions
                    ),
                  ),
                  // Ajout d'un bouton "Retour" en haut à gauche
                  Positioned(
                    top: 16.0, // Distance du haut de l'écran
                    left: 16.0, // Distance du bord gauche de l'écran
                    child: CircularIconButton(icon: Icons.arrow_back, onPressed: () => GoRouter.of(context).pop()),
                  ),
                ],
              ),
            ),
            // Les boutons en bas
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircularIconButton(icon: Icons.ios_share, onPressed: () {}),
                    CircularIconButton(
                        icon: Icons.download,
                        onPressed: () async {
                          // Télécharger l'image
                          await _saveImageToGallery(imageUrl, context);
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fonction pour télécharger l'image et l'enregistrer dans la galerie
Future<void> _saveImageToGallery(String imageUrl, BuildContext context) async {
  // Demande des permissions pour accéder à la galerie
  final permissionStatus = await PhotoManager.requestPermissionExtend();

  if (permissionStatus.isAuth) {
    try {
      // Chargement de l'image depuis les assets
      final ByteData imageData = await rootBundle.load(imageUrl);
      final Uint8List bytes = imageData.buffer.asUint8List();

      // Enregistrement de l'image dans la galerie
      final assetEntity = await PhotoManager.editor.saveImage(bytes, filename: imageUrl);

      if (assetEntity != null) {
        // Affichage d'un message de succès avec Fluttertoast
        Fluttertoast.showToast(
          msg: 'Image enregistrée avec succès dans la galerie',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Erreur lors de l\'enregistrement de l\'image',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Gestion des erreurs
      Fluttertoast.showToast(
        msg: 'Erreur : $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } else {
    // Permission refusée
    Fluttertoast.showToast(
      msg: 'Permission refusée',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0), // Ajoute un espacement autour du bouton
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // Forme circulaire
        color: Colors.black26, // Fond noir
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white), // Icône personnalisée
        onPressed: onPressed, // Fonction passée en paramètre
      ),
    );
  }
}
