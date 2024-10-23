import 'package:flutter/material.dart';

Widget scrollHForPictures({required List<String> pictures}) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),

    height: 120, // Hauteur de la liste d'images
    child: ListView.builder(
      scrollDirection: Axis.horizontal, // Pour afficher les images horizontalement
      itemCount: pictures.length,
      itemBuilder: (BuildContext context, int index) {
        return picuture(pictures[index]);
      },
    ),
  );
}

Widget picuture(String path) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 150,
      width: 100, // Utilise chaque chemin d'image dans la liste
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Bord arrondi de l'image
        child: Image.asset(
          path,
          fit: BoxFit.cover, // Utilisation de BoxFit.cover pour remplir le conteneur sans déformation
        ),
      ),
    ),
  );
}
